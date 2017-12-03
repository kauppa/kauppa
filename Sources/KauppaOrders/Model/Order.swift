import Foundation

import KauppaCore

public struct Order: Encodable {
    public let id: UUID?
    public let createdOn: Date?
    public let updatedAt: Date?
    public let products: [OrderedProduct]
    public let totalItems: UInt16
    public let totalPrice: Double
    public let totalWeight: UnitMeasurement<Weight>

    public init(id: UUID, createdOn: Date, updatedAt: Date, products: [OrderedProduct], totalItems: UInt16, totalPrice: Double, totalWeight: UnitMeasurement<Weight>) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = updatedAt
        self.products = products
        self.totalItems = totalItems
        self.totalPrice = totalPrice
        self.totalWeight = totalWeight
    }

    public init(products: [OrderedProduct]) {
        self.id = nil
        self.createdOn = nil
        self.updatedAt = nil
        self.products = products
        self.totalItems = 0
        self.totalPrice = 0.0
        self.totalWeight = UnitMeasurement(value: 0.0, unit: .gram)
    }
}
