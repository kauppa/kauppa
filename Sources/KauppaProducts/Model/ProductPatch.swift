import Foundation

import KauppaCore

/// This has all fields from `ProductData`, but everything's optional.
/// It's used for an update request, where one or more of these properties
/// could be updated for a product.
public struct ProductPatch: Decodable {
    public var title: String?
    public var subtitle: String?
    public var description: String?
    public var category: ProductCategory?
    public var size: Size?
    public var color: String?
    public var weight: UnitMeasurement<Weight>?
    public var inventory: UInt32?
    public var images: Set<String>?
    public var price: Double?
    public var variantId: UUID?

    public init() {
        title = nil
        subtitle = nil
        description = nil
        category = nil
        size = nil
        color = nil
        weight = nil
        inventory = nil
        images = nil
        price = nil
        variantId = nil
    }
}
