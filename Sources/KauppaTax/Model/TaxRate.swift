import KauppaCore

/// Tax rate information for a specific country or region. All values are
/// supposed to be in percentages.
public struct TaxRate: Mappable {
    /// Tax rate for any product.
    public var general: Float = 0.0
    /// Tax rates for different categories of products in the country/region.
    public var categories = [String: Float]()

    public init() {}

    /// Validate the data in this object.
    public func validate() throws {
        if general < 0.0 || general > 50.0 {    // disallow rates > 50%
            throw TaxError.invalidTaxRate
        }

        for (category, rate) in categories {
            if rate < 0.0 || rate > 50.0 {
                throw TaxError.invalidCategoryTaxRate(category)
            }
        }
    }
}
