import Foundation

import KauppaCore
import KauppaAccountsClient
import KauppaAccountsModel
import KauppaOrdersClient
import KauppaOrdersModel
import KauppaOrdersRepository
import KauppaProductsClient
import KauppaProductsModel
import KauppaShipmentsClient
import KauppaShipmentsModel

/// Service that manages orders placed by customers.
public class OrdersService {
    let repository: OrdersRepository
    let accountsService: AccountsServiceCallable
    let productsService: ProductsServiceCallable
    let shippingService: ShipmentsServiceCallable

    var mailService: MailClient? = nil

    /// Initialize this service with its repository, along with
    /// instances of clients to account and product services.
    public init(withRepository repository: OrdersRepository,
                accountsService: AccountsServiceCallable,
                productsService: ProductsServiceCallable,
                shippingService: ShipmentsServiceCallable)
    {
        self.repository = repository
        self.accountsService = accountsService
        self.productsService = productsService
        self.shippingService = shippingService
    }
}

// NOTE: See the actual protocol in `KauppaOrdersClient` for exact usage.
extension OrdersService: OrdersServiceCallable {
    public func createOrder(data: OrderData) throws -> Order {
        let account = try accountsService.getAccount(id: data.placedBy)
        var order = Order(placedBy: account.id)
        // order data for mail service
        var detailedOrder: DetailedOrder = GenericOrder(placedBy: account)

        order.placedBy = data.placedBy
        order.shippingAddress = data.shippingAddress
        order.billingAddress = data.billingAddress
        detailedOrder.placedBy = account

        var productPrice = 0.0
        var priceUnit: Currency? = nil
        var totalPrice = 0.0
        let weightCounter = WeightCounter()
        var inventoryUpdates = [UUID: UInt32]()

        for orderUnit in data.products {
            var orderUnit = orderUnit
            orderUnit.status = nil          // reset unit status
            if orderUnit.quantity == 0 {
                continue    // skip zero'ed items
            }

            let product = try productsService.getProduct(id: orderUnit.product)
            // check that all products are in the same currency
            productPrice = product.data.price.value
            if let unit = priceUnit {
                if unit != product.data.price.unit {
                    throw OrdersError.ambiguousCurrencies
                }
            } else {
                priceUnit = product.data.price.unit
            }

            // Also check for duplicate product
            let available = inventoryUpdates[product.id] ?? product.data.inventory
            if available < orderUnit.quantity {
                throw OrdersError.productUnavailable
            }

            let leftover = available - UInt32(orderUnit.quantity)
            inventoryUpdates[product.id] = leftover
            order.products.append(orderUnit)
            let unit = GenericOrderUnit(product: product,
                                        quantity: orderUnit.quantity)
            detailedOrder.products.append(unit)

            totalPrice += Double(orderUnit.quantity) * productPrice
            var weight = product.data.weight ?? UnitMeasurement(value: 0.0, unit: .gram)
            weight.value *= Double(orderUnit.quantity)
            weightCounter.add(weight)
            order.totalItems += UInt16(orderUnit.quantity)
        }

        if inventoryUpdates.isEmpty {
            throw OrdersError.noItemsToProcess
        }

        for (id, leftover) in inventoryUpdates {
            var patch = ProductPatch()
            patch.inventory = leftover
            let _ = try productsService.updateProduct(id: id, data: patch)
        }

        order.totalPrice = UnitMeasurement(value: totalPrice, unit: priceUnit!)
        order.totalWeight = weightCounter.sum()
        let shipment = try shippingService.createShipment(forOrder: order.id)
        order.shipments[shipment.id] = shipment.status

        let orderData = try repository.createOrder(withData: order)
        orderData.copyValues(into: &detailedOrder)
        let mailOrder = MailOrder(from: detailedOrder)
        if let mailer = mailService {
            mailer.sendMail(to: account.data.email, with: mailOrder)
        }

        return orderData
    }

    public func getOrder(forId id: UUID) throws -> Order {
        return try repository.getOrder(id: id)
    }

    public func cancelOrder(id: UUID) throws -> Order {
        var order = try repository.getOrder(id: id)
        let date = Date()
        order.cancelledAt = date
        order.updatedAt = date
        return try repository.updateOrder(withData: order, skipDate: true)
    }

    public func initiateRefund(forId id: UUID, data: RefundData) throws -> Order {
        if data.reason.isEmpty {
            throw OrdersError.invalidReason
        }

        var order = try repository.getOrder(id: id)
        try order.validateForRefund()

        var atleastOneItemExists = false
        var refundItems = [GenericOrderUnit<Product>]()
        // TODO: Investigate payment processing

        if data.fullRefund ?? false {
            refundItems = try getAllRefundableItems(forOrder: &order)
        } else {
            for unit in data.units ?? [] {
                let i = try findEnumeratedProduct(inOrder: order, forId: unit.product)
                let productData = try productsService.getProduct(id: unit.product)
                // It's safe to unwrap here because the function checks this.
                let unitStatus = order.products[i].status!
                let refundable = unitStatus.refundableQuantity

                if unit.quantity > refundable {
                    throw OrdersError.invalidRefundQuantity(productData.id, refundable)
                }

                let unit = GenericOrderUnit(product: productData, quantity: unit.quantity)
                refundItems.append(unit)
                order.products[i].status!.refundableQuantity -= unit.quantity

                // Check whether all items have been refunded in this unit
                if unitStatus.fulfilledQuantity == 0 && refundable == unit.quantity {
                    order.products[i].status = nil
                } else {
                    order.products[i].status!.fulfillment = .partial
                }

                atleastOneItemExists = atleastOneItemExists || order.products[i].hasFulfillment
            }
        }

        if refundItems.isEmpty {
            throw OrdersError.noItemsToProcess
        }

        // If we've come this far, then it's either a partial refund or full refund.
        if atleastOneItemExists {
            order.paymentStatus = .partialRefund
            order.fulfillment = .partial
        } else {
            order.paymentStatus = .refunded
            order.fulfillment = nil
        }

        // We can assume that all products in a successfully placed
        // order *will* have the same currency, because the cart checks it.
        let currency = refundItems[0].product.data.price.unit
        var totalPrice = UnitMeasurement(value: 0.0, unit: currency)
        var items = [OrderUnit]()
        for item in refundItems {
            totalPrice.value += item.product.data.price.value * Double(item.quantity)
            let unit = OrderUnit(product: item.product.id, quantity: item.quantity)
            items.append(unit)
        }

        let refund = try repository.createRefund(forOrder: order.id, reason: data.reason,
                                                 items: items, amount: totalPrice)
        order.refunds.append(refund.id)
        return try repository.updateOrder(withData: order)
    }

    public func returnOrder(id: UUID, data: PickupData) throws -> Order {
        var order = try repository.getOrder(id: id)
        try order.validateForReturn()

        var returnItems = [OrderUnit]()

        if data.pickupAll ?? false {
            returnItems = try getAllItemsForPickup(forOrder: &order)
        } else {
            for unit in data.units ?? [] {
                let i = try findEnumeratedProduct(inOrder: order, forId: unit.product)
                let productData = try productsService.getProduct(id: unit.product)

                // Only items that have been fulfilled "and" not scheduled for pickup
                let fulfilled = order.products[i].untouchedItems()
                if unit.quantity > fulfilled {
                    throw OrdersError.invalidReturnQuantity(productData.id, fulfilled)
                }

                let unit = OrderUnit(product: productData.id, quantity: unit.quantity)
                returnItems.append(unit)
                order.products[i].status!.pickupQuantity += unit.quantity
            }
        }

        if returnItems.isEmpty {
            throw OrdersError.noItemsToProcess
        }

        var pickupData = PickupItems()
        pickupData.items = returnItems
        let shipment = try shippingService.schedulePickup(forOrder: order.id, data: pickupData)
        order.shipments[shipment.id] = shipment.status

        return try repository.updateOrder(withData: order)
    }

    public func updateShipment(forId id: UUID, data: Shipment) throws -> () {
        if data.items.isEmpty {
            throw OrdersError.noItemsToProcess
        }

        var order = try repository.getOrder(id: id)
        order.shipments[data.id] = data.status
        // NOTE: The `items` in `Shipment` data should never be empty, because
        // it's called only by orders and it's responsible for supplying the items.

        switch data.status {
            case .returned:
                try handlePickupEvent(forOrder: &order, data: data)
            case .delivered:
                try handleDeliveryEvent(forOrder: &order, data: data)

            default: ()
        }

        let _ = try repository.updateOrder(withData: order)
        return ()
    }

    public func deleteOrder(id: UUID) throws -> () {
        return try repository.deleteOrder(id: id)
    }

    /* Private functions */

    /// Shipment has reached the customer. Set the fulfillment quantity for
    /// each order unit, which indicates the number of items delivered.
    func handleDeliveryEvent(forOrder order: inout Order, data: Shipment) throws -> () {
        for unit in data.items {
            let i = try findEnumeratedProduct(inOrder: order, forId: unit.product,
                                              expectFulfillment: false)
            let expectedQuantity = order.products[i].quantity
            if unit.quantity > expectedQuantity {
                throw OrdersError.invalidDeliveryQuantity(unit.product, expectedQuantity)
            }

            order.products[i].status = OrderUnitStatus(quantity: unit.quantity)
        }

        return ()
    }

    /// Handle the pickup event from shipments service, such that the items successfully picked up
    /// have been reflected in the corresponding `Order` data.
    func handlePickupEvent(forOrder order: inout Order, data: Shipment) throws -> () {
        for unit in data.items {
            let i = try findEnumeratedProduct(inOrder: order, forId: unit.product)
            let scheduled = order.products[i].status!.pickupQuantity    // safe to unwrap here
            if unit.quantity > scheduled {      // picked up more than what was scheduled
                throw OrdersError.invalidPickupQuantity(order.products[i].product, scheduled)
            }

            order.products[i].status!.pickupQuantity -= unit.quantity

            let delivered = order.products[i].status!.fulfilledQuantity
            if unit.quantity > delivered {
                throw OrdersError.unfulfilledItem(unit.product)
            }

            order.products[i].status!.fulfilledQuantity -= unit.quantity
            order.products[i].status!.refundableQuantity += unit.quantity
        }

        return ()
    }

    /// Given a product ID and order data, this function finds the index
    /// of that product item in the order, gets the product data from the products
    /// service (if any), and ensures that the order item has been fulfilled.
    func findEnumeratedProduct(inOrder order: Order, forId id: UUID,
                               expectFulfillment: Bool = true) throws -> Int {
        for (idx, orderUnit) in order.products.enumerated() {
            if id != orderUnit.product {
                continue
            }

            // Make sure that only fulfilled (delivered) items are returned/refunded/picked up.
            if expectFulfillment && orderUnit.status == nil {
                throw OrdersError.unfulfilledItem(id)
            }

            return idx
        }

        throw OrdersError.invalidOrderItem      // no such item exists in order.
    }

    /// Returns a list of all items that can be picked up from this order. This actually
    /// changes the `pickupQuantity` in each order unit (to indicate that the items have
    /// been scheduled for pickup).
    func getAllItemsForPickup(forOrder data: inout Order) throws -> [OrderUnit] {
        var returnItems = [OrderUnit]()
        for (i, unit) in data.products.enumerated() {
            let product = try productsService.getProduct(id: unit.product)
            // Only collect "untouched" items (if any) from each unit
            // (i.e., items that have been fulfilled and not scheduled for pickup)
            let fulfilled = unit.untouchedItems()
            if fulfilled > 0 {
                let returnUnit = OrderUnit(product: product.id, quantity: fulfilled)
                returnItems.append(returnUnit)
                data.products[i].status!.pickupQuantity += returnUnit.quantity
            }
        }

        return returnItems
    }

    /// Returns a list of all refundable items in this order. If there's no fulfilled
    /// quantity after processing the refundable items in an unit, then the unit status
    /// will be set to `nil`
    func getAllRefundableItems(forOrder data: inout Order) throws
                              -> [GenericOrderUnit<Product>]
    {
        var refundItems = [GenericOrderUnit<Product>]()
        for (i, unit) in data.products.enumerated() {
            let product = try productsService.getProduct(id: unit.product)
            // Only collect fulfilled items (if any) from each unit.
            if let unitStatus = unit.status {
                if unitStatus.refundableQuantity > 0 {
                    let refundUnit = GenericOrderUnit(product: product,
                                                      quantity: unitStatus.refundableQuantity)
                    data.products[i].status!.refundableQuantity = 0    // reset refundable quantity
                    refundItems.append(refundUnit)
                }

                // This is the last step in return + refund process. So, if there are
                // no fulfilled items, then we can safely reset this state.
                if unitStatus.fulfilledQuantity == 0 {
                    data.products[i].status = nil
                }
            }
        }

        return refundItems
    }
}
