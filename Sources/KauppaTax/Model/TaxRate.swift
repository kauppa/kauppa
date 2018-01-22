import KauppaCore

/// Tax rate information for a specific country or region. All values are
/// supposed to be in percentages.
public struct TaxRate: Mappable {
    /// Tax rate for any product.
    public var general: Float = 0.0
    /// Tax rates for different categories of products in the country/region.
    /// (also called tax classes)
    public var categories = [String: Float]()

    public init() {}
}
