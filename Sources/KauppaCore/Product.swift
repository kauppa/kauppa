import Foundation

public struct ProductData: Codable {
    let title: String
    let subtitle: String
    let description: String
    let size: Size?
    let color: String?
    let weight: UnitMeasurement<Weight>?
    var inventory: UInt32
    let images: [String]
    let price: Double       // NOTE: Let's stick to one unit for now
    let variantId: UUID?
    // ...
}

public struct Product: Encodable {
    let id: UUID
    let createdOn: Date
    let updatedAt: Date
    var data: ProductData
    // ...
}
