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

    /// Validate the data in this object.
    public func validate() throws {
        if general < 0.0 || general > 1000.0 {  // disallow rates > 1000%
            throw TaxError.invalidTaxRate
        }

        for (category, rate) in categories {
            if rate < 0.0 || rate > 1000.0 {
                throw TaxError.invalidCategoryTaxRate(category)
            }
        }
    }
}
