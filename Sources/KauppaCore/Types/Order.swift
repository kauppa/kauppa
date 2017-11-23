import Foundation

public struct OrderUnit: Codable {
    let id: UUID
    let quantity: UInt8
}

public struct OrderData: Codable {
    let products: [OrderUnit]
}

public struct OrderedProduct: Encodable {
    let data: Product?
    let productExists: Bool
    let processedItems: UInt8
}

public struct Order: Encodable {
    let id: UUID
    let createdOn: Date
    let updatedAt: Date
    let products: [OrderedProduct]
    let totalItems: UInt16
    let totalPrice: Double
    let totalWeight: UnitMeasurement<Weight>
}
