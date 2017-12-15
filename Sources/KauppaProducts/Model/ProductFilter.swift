import Foundation

import KauppaCore

/// A filter applied for getting products.
public struct ProductFilter: Mappable {
    /// Tags that belong in this collection
    public var tags = ArraySet<String>()
    /// Categories that belong in this collection
    public var categories = [String]()
    /// Lower bound for price in this collection.
    public var minPrice: UnitMeasurement<Currency>? = nil
    /// Upper bound for price in this collection.
    public var maxPrice: UnitMeasurement<Currency>? = nil
    /// Color constraint for the products
    public var color: String? = nil
    /// Minimum number of items available in the inventory.
    public var minAvailable: UInt32
    /// Lower bound on the weight of product.
    public var minWeight: UnitMeasurement<Weight>? = nil
    /// Upper bound on the weight of product.
    public var maxWeight: UnitMeasurement<Weight>? = nil
}
