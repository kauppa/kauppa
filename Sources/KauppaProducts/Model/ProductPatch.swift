import Foundation

import KauppaCore

public struct ProductPatch: Decodable {
    public let title: String?
    public let subtitle: String?
    public let description: String?
    public let category: ProductCategory?
    public let size: Size?
    public let color: String?
    public let weight: UnitMeasurement<Weight>?
    public let inventory: UInt32?
    public let image: String?
    public let price: Double?
    public let variantId: UUID?
}
