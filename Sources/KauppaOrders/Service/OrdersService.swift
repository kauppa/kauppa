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
}
