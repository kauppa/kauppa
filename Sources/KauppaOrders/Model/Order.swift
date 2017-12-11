import Foundation

import KauppaCore

/// Order that only has the product IDs and quantity
public typealias Order = GenericOrder<UUID, OrderedProduct>

/// Generic order structure for holding product data.
public struct GenericOrder<U: Mappable, P: Mappable>: Mappable {
    /// Unique identifier for this order.
    public var id: UUID?
    /// User ID associated with this order.
    public var placedBy: U?
    /// Creation timestamp
    public var createdOn: Date?
    /// Last updated timestamp
    public var updatedAt: Date?
    /// List of product IDs and the associated quantity
    public var products: [P]
    /// Total number of items processed (includes the quantity)
    public var totalItems: UInt16
    /// Total price of all items (includes the quantity)
    public var totalPrice: UnitMeasurement<Currency>
    /// Total weight of this purchase (includes the quantity)
    public var totalWeight: UnitMeasurement<Weight>

    public init() {
        self.id = nil
        self.placedBy = nil
        self.createdOn = nil
        self.updatedAt = nil
        self.products = []
        self.totalItems = 0
        self.totalPrice = UnitMeasurement(value: 0.0, unit: .usd)
        self.totalWeight = UnitMeasurement(value: 0.0, unit: .gram)
    }
}
