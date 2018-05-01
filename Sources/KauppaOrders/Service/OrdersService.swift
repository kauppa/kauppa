import Foundation

import KauppaCore
import KauppaAccountsClient
import KauppaAccountsModel
import KauppaCouponClient
import KauppaOrdersClient
import KauppaOrdersModel
import KauppaOrdersRepository
import KauppaProductsClient
import KauppaProductsModel
import KauppaShipmentsClient
import KauppaShipmentsModel
import KauppaTaxClient

/// Service that manages orders placed by customers.
public class OrdersService {
    let repository: OrdersRepository
    let accountsService: AccountsServiceCallable
    let productsService: ProductsServiceCallable
    let couponService: CouponServiceCallable
    let taxService: TaxServiceCallable

    /// NOTE: Even though this definition says that the shipping service is optional,
    /// it's not. The orders service "needs" the shipments service. It's optional
    /// only because both the services cyclically depend on each other and we needed
    /// a way to instantiate both the services properly.
    public var shippingService: ShipmentsServiceCallable? = nil

    /// `MailClient` for sending mails.
    public var mailService: MailClient? = nil

    /// Initialize this service with its repository, along with
    /// instances of clients to account and product services.
    ///
    /// - Parameters:
    ///   - with: `OrdersRepository`
    ///   - accountsService: Anything that implements `AccountsServiceCallable`
    ///   - productsService: Anything that implements `ProductsServiceCallable`
    ///   - shippingService: Anything that implements `ShipmentsServiceCallable`
    ///   - couponService: Anything that implements `CouponServiceCallable`
    ///   - taxService: Anything that implements `TaxServiceCallable`
    public init(with repository: OrdersRepository,
                accountsService: AccountsServiceCallable,
                productsService: ProductsServiceCallable,
                shippingService: ShipmentsServiceCallable?,
                couponService: CouponServiceCallable,
                taxService: TaxServiceCallable)
    {
        self.repository = repository
        self.accountsService = accountsService
        self.productsService = productsService
        self.shippingService = shippingService
        self.couponService = couponService
        self.taxService = taxService
    }
}

// NOTE: See the actual protocol in `KauppaOrdersClient` for exact usage.
extension OrdersService: OrdersServiceCallable {
    public func createOrder(with data: OrderData) throws -> Order {
        let account = try accountsService.getAccount(for: data.placedBy)
        if !account.isVerified {
            throw ServiceError.unverifiedAccount
        }

        let factory = OrdersFactory(with: data, from: account, using: productsService)
        try factory.createOrder(with: shippingService!, using: couponService,
                                calculatingWith: taxService)
        let detailedOrder = factory.createOrder()

        try repository.createOrder(with: factory.order)
        let mailOrder = MailOrder(from: detailedOrder)
        if let mailer = mailService {
            mailer.sendMail(to: account.getVerifiedEmails(), with: mailOrder)
        }

        return factory.order
    }

    public func getOrder(for id: UUID) throws -> Order {
        return try repository.getOrder(for: id)
    }

    public func cancelOrder(for id: UUID) throws -> Order {
        var order = try repository.getOrder(for: id)
        let date = Date()
        order.cancelledAt = date
        order.updatedAt = date
        return try repository.updateOrder(with: order, skippingDate: true)
    }

    public func initiateRefund(for id: UUID, with data: RefundData) throws -> Order {
        var order = try repository.getOrder(for: id)
        let factory = RefundsFactory(with: data, using: productsService)
        try factory.initiateRefund(for: &order, using: repository)
        return try repository.updateOrder(with: order)
    }

    public func returnOrder(for id: UUID, with data: PickupData) throws -> Order {
        var order = try repository.getOrder(for: id)
        let factory = ReturnsFactory(with: data, using: productsService)
        try factory.initiatePickup(for: &order, with: shippingService!)
        return try repository.updateOrder(with: order)
    }

    public func updateShipment(for id: UUID, with data: Shipment) throws -> () {
        if data.items.isEmpty {
            throw ServiceError.noItemsToProcess
        }

        var order = try repository.getOrder(for: id)
        order.shipments[data.id] = data.status
        // NOTE: The `items` in `Shipment` data should never be empty, because
        // it's called only by orders and it's responsible for supplying the items.

        switch data.status {
            case .returned:
                try handlePickupEvent(for: &order, with: data)
            case .delivered:
                try handleDeliveryEvent(for: &order, with: data)

            default: ()
        }

        let _ = try repository.updateOrder(with: order)
    }

    public func deleteOrder(for id: UUID) throws -> () {
        return try repository.deleteOrder(for: id)
    }
}
