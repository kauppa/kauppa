import Foundation

import KauppaCore

public struct Order: Encodable {
    public var id: UUID?
    public var createdOn: Date?
    public var updatedAt: Date?
    public var products: [OrderedProduct]
    public var totalItems: UInt16
    public var totalPrice: Double
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
