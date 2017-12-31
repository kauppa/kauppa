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
public class OrdersService: OrdersServiceCallable {
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
            let product = try productsService.getProduct(id: orderUnit.product)
            if orderUnit.quantity == 0 {
                continue    // skip zero'ed items
            }

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
                var product: Product? = nil
                var unitIdx: Int? = nil
                for i in 0..<order.products.count {
                    let id = order.products[i].product
                    if unit.product != id {
                        continue
                    }

                    product = try productsService.getProduct(id: id)
                    unitIdx = i
                }

                // Make sure that all products in the request are valid
                guard let productData = product, let i = unitIdx else {
                    throw OrdersError.invalidOrderItem
                }

                // Only fulfilled items can be refunded.
                guard let unitStatus = order.products[i].status else {
                    throw OrdersError.unfulfilledItem(productData.id)
                }

                let refundable = unitStatus.refundableQuantity
                if unit.quantity > refundable {
                    throw OrdersError.invalidOrderQuantity(productData.id, refundable, true)
                }

                let unit = GenericOrderUnit(product: productData, quantity: unit.quantity)
                refundItems.append(unit)
                order.products[i].status!.refundableQuantity -= unit.quantity

                // all items have been refunded in this unit
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
        // order *will* have the same currency.
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
                var product: Product? = nil
                var unitIdx: Int? = nil
                for i in 0..<order.products.count {
                    let id = order.products[i].product
                    if unit.product != id {
                        continue
                    }

                    product = try productsService.getProduct(id: id)
                    unitIdx = i
                }

                // Make sure that all products are valid
                guard let productData = product, let i = unitIdx else {
                    throw OrdersError.invalidOrderItem
                }

                // Only fulfilled (delivered) items can be returned.
                guard let _ = order.products[i].status else {
                    throw OrdersError.unfulfilledItem(productData.id)
                }

                // Only items that have been fulfilled "and" not scheduled for pickup
                let fulfilled = order.products[i].untouchedItems()
                if unit.quantity > fulfilled {
                    throw OrdersError.invalidOrderQuantity(productData.id, fulfilled, false)
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
        let _ = try repository.getOrder(id: id)
        // TODO: Detect changes from shipment data (refund, return, etc.)
        return ()
    }

    public func deleteOrder(id: UUID) throws -> () {
        return try repository.deleteOrder(id: id)
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
