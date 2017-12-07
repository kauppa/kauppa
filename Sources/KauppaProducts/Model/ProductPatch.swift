import Foundation

import KauppaCore

/// This has all fields from `ProductData`, but everything's optional.
/// It's used for an update request, where one or more of these properties
/// could be updated for a product.
public struct ProductPatch: Mappable {
    public var title: String? = nil
    public var subtitle: String? = nil
    public var description: String? = nil
    public var category: ProductCategory? = nil
    public var size: Size? = nil
    public var color: String? = nil
    public var weight: UnitMeasurement<Weight>? = nil
    public var inventory: UInt32? = nil
    public var images: Set<String>? = nil
    public var price: Double? = nil
    public var variantId: UUID? = nil

    public init() {}
}
