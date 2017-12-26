import Foundation

import KauppaCore

/// This has all fields from `ProductData`, but everything's optional.
/// It's used for an update request, where one or more of these properties
/// could be updated for a product.
public struct ProductPatch: Mappable {
    public var title: String? = nil
    public var subtitle: String? = nil
    public var description: String? = nil
    public var category: String? = nil
    public var dimensions: Dimensions? = nil
    public var color: String? = nil
    public var weight: UnitMeasurement<Weight>? = nil
    public var inventory: UInt32? = nil
    public var images: ArraySet<String>? = nil
    public var price: UnitMeasurement<Currency>? = nil
    public var taxInclusive: Bool? = nil
    public var variantId: UUID? = nil
    public var custom: [CustomAttribute]? = nil

    /// Initialize an empty instance with all fields set to `nil`
    public init() {}
}

/// This adds individual items to the collections residing in `ProductData`
public struct ProductPropertyAdditionPatch: Mappable {
    public var image: String? = nil
}

/// This has the nullable items from `ProductData` - any delete
/// request having one or more of these fields set to `true`
/// will reset that field in `ProductData`
public struct ProductPropertyDeletionPatch: Mappable {
    public var removeCategory: Bool? = nil
    public var removeColor: Bool? = nil
    public var removeDimensions: Bool? = nil
    public var removeWeight: Bool? = nil
    public var removeImageAt: Int? = nil
    public var removeVariant: Bool? = nil
}
