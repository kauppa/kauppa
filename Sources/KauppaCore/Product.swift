import Foundation

public struct ProductPatch: Decodable {
    let title: String?
    let subtitle: String?
    let description: String?
    let size: Size?
    let color: String?
    let weight: UnitMeasurement<Weight>?
    let inventory: UInt32?
    let images: [String]?
    let price: Double?
    let variantId: UUID?
}

public struct ProductData: Codable {
    var title: String
    var subtitle: String
    var description: String
    var size: Size?
    var color: String?
    var weight: UnitMeasurement<Weight>?
    var inventory: UInt32
    var images: [String]
    var price: Double       // NOTE: Let's stick to one unit for now
    var variantId: UUID?
    // ...
}

public struct Product: Encodable {
    let id: UUID
    let createdOn: Date
    var updatedAt: Date
    var data: ProductData
    // ...
}
