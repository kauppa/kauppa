import Foundation

import KauppaCore

/// Order that only has the product IDs and quantity
public typealias Order = GenericOrder<UUID, OrderUnit>

/// Generic order structure for holding product data.
public struct GenericOrder<U: Mappable, P: Mappable>: Mappable {
    /// Unique identifier for this order.
    public var id: UUID? = nil
    /// User ID associated with this order.
    public var placedBy: U? = nil
    /// Creation timestamp
    public var createdOn: Date? = nil
    /// Last updated timestamp
    public var updatedAt: Date? = nil
    /// List of product IDs and the associated quantity
    public var products = [P]()
    /// Total number of items processed (includes the quantity)
    public var totalItems: UInt16
    /// Total price of all items (includes the quantity) without tax/shipping.
    public var totalPrice: UnitMeasurement<Currency>
    /// Total weight of this purchase (includes the quantity)
    public var totalWeight: UnitMeasurement<Weight>
    /// Status of this order.
    public var fulfillment: FulfillmentStatus? = nil
    /// Payment status for this order.
    public var paymentStatus: PaymentStatus = .pending
    /// Cancellation date (if this order was cancelled)
    public var cancelledAt: Date? = nil
    /// Refunds created for this order.
    public var refunds = [UUID]()

    public init() {
        self.totalItems = 0
        self.totalPrice = UnitMeasurement(value: 0.0, unit: .usd)
        self.totalWeight = UnitMeasurement(value: 0.0, unit: .gram)
    }

    /// Copy the type-independent values from this type to a mail-specific order.
    public func copyValues<U, P>(into data: inout GenericOrder<U, P>) {
        data.id = id
        data.createdOn = createdOn
        data.updatedAt = updatedAt
        data.totalItems = totalItems
        data.totalPrice = totalPrice
        data.totalWeight = totalWeight
    }
}
