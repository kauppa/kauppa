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
    public var category: String? = nil
    /// Tags for this product
    public var tags: [String] = []
    /// Size of this product (length, width and height - all are optional)
    public var size: Size? = nil
    /// Color in hex code
    public var color: String? = nil
    /// Weight of this product in some chosen measurement.
    public var weight: UnitMeasurement<Weight>?
    /// Amount of items of this product in the inventory
    public var inventory: UInt32 = 0
    /// Base64-encoded images
    public var images = ArraySet<String>()
    /// Price of the product in some chosen currency
    // FIXME: Avoid `Double` to avoid floating point disasters.
    public var price: UnitMeasurement<Currency> = UnitMeasurement(value: 0, unit: .usd)
    /// (child) variants of this product. For now, the variants belong to a single parent
    /// product, and hence this is an internal property. It shouldn't be updated
    /// manually by the user. Instead, the user should attach the ID of the parent
    /// product to the child through `variantId`
    public var variants = Set<UUID>()
    /// ID of the (parent) product to which this is a variant. Attaching this will
    /// automatically add this product to the parent's variants.
    public var variantId: UUID? = nil

    public init(title: String, subtitle: String, description: String) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
    }
}
