import Foundation

import KauppaCore
import KauppaAccountsModel

/// Order type in which the user, products and coupons are represented with their IDs.
public typealias Order = GenericOrder<UUID, UUID, OrderUnit>

/// Generic order structure for holding product data.
public struct GenericOrder<User: Mappable, Coupon: Mappable, Item: Mappable>: Mappable {
    /// Unique identifier for this order.
    public var id: UUID
    /// User ID associated with this order.
    public var placedBy: User
    /// Creation timestamp
    public var createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// List of product IDs and the associated quantity
    public var products = [Item]()
    /// Total number of items processed (includes the quantity)
    public var totalItems: UInt16 = 0
    /// Currency used in this order.
    public var currency = Currency.usd
    /// Total price of all items (includes the quantity) without tax/shipping.
    public var netPrice = Price()
    /// Total tax for this order.
    public var totalTax = Price()
    /// List of coupons applied in this order.
    public var appliedCoupons = [Coupon]()
    /// Final price after adding taxes, shipment fee and coupon deductions (if any)
    public var grossPrice = Price()
    /// Total weight of this purchase (includes the quantity)
    public var totalWeight = UnitMeasurement(value: 0.0, unit: Weight.gram)
    /// Status of this order.
    public var fulfillment: FulfillmentStatus? = nil
    /// Payment status for this order.
    public var paymentStatus: PaymentStatus = .pending
    /// Cancellation date (if this order was cancelled)
    public var cancelledAt: Date? = nil
    /// Refunds created for this order.
    public var refunds = [UUID]()
    /// Shipments initiated for this order.
    public var shipments = [UUID: ShipmentStatus]()
    /// Billing address for this order.
    public var billingAddress: Address
    /// Shipping Address for this order.
    public var shippingAddress: Address

    /// Creates an order with the given account (generic type). By default,
    /// the shipping and billing addresses are invalid.
    ///
    /// - Parameters:
    ///   - placedBy: The user account which placed the order.
    public init(placedBy account: User) {
        id = UUID()
        let date = Date()
        createdOn = date
        updatedAt = date
        placedBy = account
        billingAddress = Address()
        shippingAddress = Address()
    }

    /// Copy the type-independent values from this instance to another instance.
    /// This is used while sending mail.
    ///
    /// - Parameters:
    ///   - into: The other order type to which the values should be copied.
    public func copyValues<U, G, P>(into data: inout GenericOrder<U, G, P>) {
        data.id = id
        data.createdOn = createdOn
        data.updatedAt = updatedAt
        data.totalItems = totalItems
        data.netPrice = netPrice
        data.totalTax = totalTax
        data.grossPrice = grossPrice
        data.totalWeight = totalWeight
        data.fulfillment = fulfillment
        data.paymentStatus = paymentStatus
        data.cancelledAt = cancelledAt
        data.refunds = refunds
        data.shipments = shipments
        data.billingAddress = billingAddress
        data.shippingAddress = shippingAddress
    }

    /// Validate this order to check whether it's suitable for refunding.
    ///
    /// - Throws: `ServiceError` on failure.
    public func validateForRefund() throws {
        if let _ = cancelledAt {
            throw ServiceError.cancelledOrder
        }

        switch paymentStatus {
            case .refunded:     // All items have been refunded
                throw ServiceError.refundedOrder
            case .failed, .pending:
                throw ServiceError.paymentNotReceived
            default:
                break
        }
    }

    /// Validate this order to check whether it's suitable for returning.
    ///
    /// - Throws: `ServiceError` if this order cannot be returned.
    public func validateForReturn() throws {
        if let _ = cancelledAt {
            throw ServiceError.cancelledOrder
        }
    }
}
