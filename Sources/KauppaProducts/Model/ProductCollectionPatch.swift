import Foundation

import KauppaCore

/// This has all fields from `ProductCollectionData`, but everything's optional.
/// It's used for an update request, where one or more of these properties
/// could be updated for a product.
public struct ProductCollectionPatch: Mappable {
    public var name: String? = nil
    public var description: String? = nil
    public var products: Set<UUID>? = nil

    public init() {}
}

/// This representes individual products to be added/removed to/from
/// the collection. If multiple products are given, then they're all
/// merged with union or set subtraction.
public struct ProductCollectionItemPatch: Mappable {
    public var product: UUID? = nil
    public var products: [UUID]? = nil

    public init() {}
}
