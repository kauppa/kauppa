import Foundation

import KauppaCore

public struct ProductData: Codable {
    public var title: String
    public var subtitle: String
    public var description: String
    public var category: ProductCategory?
    public var size: Size?
    public var color: String?
    public var weight: UnitMeasurement<Weight>?
    public var inventory: UInt32
    public var images: [String]     // FIXME: Change to set
    public var price: Double        // NOTE: Let's stick to one unit for now
    /// (child) variants of this product. For now, the variants belong to a single parent
    /// product, and hence this is an internal property. It shouldn't be updated
    /// manually by the user. Instead, the user should attach the ID of the parent
    /// product to the child through `variantId`
    public var variants: Set<UUID>
    /// ID of the (parent) product to which this is a variant. Attaching this will
    /// automatically add this product to the parent's variants.
    public var variantId: UUID?

    public init(title: String, subtitle: String, description: String) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.inventory = 0
        self.images = []
        self.variants = []
        self.price = 0
    }

    public init(title: String, subtitle: String, description: String, inventory: UInt32, images: [String], price: Double) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.inventory = inventory
        self.images = images
        self.variants = []
        self.price = price
    }
}
