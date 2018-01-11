import Foundation

import KauppaCore
import KauppaAccountsModel

/// Order that only has the product IDs and quantity
public typealias Order = GenericOrder<UUID, UUID, OrderUnit>

/// Generic order structure for holding product data.
public struct GenericOrder<User: Mappable, Card: Mappable, Item: Mappable>: Mappable {
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
    /// Total price of all items (includes the quantity) without tax/shipping.
    public var totalPrice = UnitMeasurement(value: 0.0, unit: Currency.usd)
    /// List of gift cards applied in this order.
    public var appliedGiftCards = [Card]()
    /// Final price after adding taxes, shipment fee and applying gift cards (if any)
    public var finalPrice = UnitMeasurement(value: 0.0, unit: Currency.usd)
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
    /// the shipping an billing addresses are invalid.
    public init(placedBy account: User) {
        id = UUID()
        let date = Date()
        createdOn = date
        updatedAt = date
        placedBy = account
        billingAddress = Address()
        shippingAddress = Address()
    }

    /// Copy the type-independent values from this type to a mail-specific order.
    public func copyValues<U, G, P>(into data: inout GenericOrder<U, G, P>) {
        data.id = id
        data.createdOn = createdOn
        data.updatedAt = updatedAt
        data.totalItems = totalItems
        data.totalPrice = totalPrice
        data.finalPrice = finalPrice
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
    public func validateForRefund() throws {
        if let _ = cancelledAt {
            throw OrdersError.cancelledOrder
        }

        switch paymentStatus {
            case .refunded:     // All items have been refunded
                throw OrdersError.refundedOrder
            case .failed, .pending:
                throw OrdersError.paymentNotReceived
            default:
                break
        }
    }

    /// Validate this order to check whether it's suitable for returning.
    public func validateForReturn() throws {
        if let _ = cancelledAt {
            throw OrdersError.cancelledOrder
        }
    }
}
