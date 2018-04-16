import KauppaCore

/// Tax data for an unit (product, cart unit or order unit).
public struct UnitTax: Mappable {
    /// Category of the product.
    public var category: String? = nil
    /// Tax rate used for this product
    public var rate: Double = 0.0
    /// Tax for this item i.e., `quantity` times `taxRate` (set by service).
    public var total = UnitMeasurement(value: 0.0, unit: Currency.usd)

    /// Initialize an instance with `nil` category and tax rate set to "0"
    public init() {}
}
