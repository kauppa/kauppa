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
        let factory = OrdersFactory(with: data, by: account, service: productsService)
        try factory.createOrder(withShipping: shippingService)
        let detailedOrder = factory.createOrder()

        try repository.createOrder(withData: factory.order)
        let mailOrder = MailOrder(from: detailedOrder)
        if let mailer = mailService {
            mailer.sendMail(to: account.data.email, with: mailOrder)
        }

        return factory.order
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
        let factory = RefundsFactory(with: data, using: repository, service: productsService)
        let order = try factory.initiateRefund(forId: id)
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
                let i = try OrdersService.findEnumeratedProduct(inOrder: order, forId: unit.product)
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
