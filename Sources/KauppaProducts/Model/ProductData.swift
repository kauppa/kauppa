import Foundation

import KauppaCore

public struct ProductData: Mappable {
    /// Title to be shown everywhere
    public var title: String
    /// A subtitle for this product
    public var subtitle: String
    /// A description of this product
    public var description: String
    /// Category on which this product belongs to
    public var category: ProductCategory?
    /// Size of this product (length, width and height - all are optional)
    public var size: Size?
    /// Color in hex code
    public var color: String?
    /// Weight of this product in some chosen measurement.
    public var weight: UnitMeasurement<Weight>?
    /// Amount of items of this product in the inventory
    public var inventory: UInt32
    /// Base64-encoded images
    public var images: ArraySet<String>
    /// Price of the product in some chosen currency
    /// NOTE: We're sticking to one unit for now
    public var price: Double    // FIXME: Avoid `Double` to avoid floating point disasters.
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
        self.images = ArraySet()
        self.variants = []
        self.price = 0
    }
}
