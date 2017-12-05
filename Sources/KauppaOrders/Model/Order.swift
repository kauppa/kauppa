import Foundation

import KauppaCore

public struct Order: Mappable {
    /// Unique identifier for this order.
    public var id: UUID?
    /// Creation timestamp
    public var createdOn: Date?
    /// Last updated timestamp
    public var updatedAt: Date?
    /// List of product IDs and the associated quantity
    public var products: [OrderedProduct]
    /// Total number of items processed (includes the quantity)
    public var totalItems: UInt16
    /// Total price of all items (includes the quantity)
    public var totalPrice: Double
    /// Total weight of this purchase (includes the quantity)
    public var totalWeight: UnitMeasurement<Weight>

    public init() {
        self.id = nil
        self.createdOn = nil
        self.updatedAt = nil
        self.products = []
        self.totalItems = 0
        self.totalPrice = 0.0
        self.totalWeight = UnitMeasurement(value: 0.0, unit: .gram)
    }
}
