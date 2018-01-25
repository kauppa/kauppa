import Foundation

import KauppaCore
import KauppaTaxModel

/// A cart unit where the product is represented by its UUID.
public typealias CartUnit = GenericCartUnit<UUID>

/// A cart unit represents a product with the specified quantity.
public struct GenericCartUnit<P: Mappable>: Mappable {
    /// Product information.
    public var product: P
    /// Required quantity of this product.
    public var quantity: UInt8
    /// Tax data for this cart unit (set by service).
    public var tax: UnitTax? = nil
    /// The price of this unit without tax (set by service).
    public var netPrice: UnitMeasurement<Currency>? = nil
    /// The price of this unit with tax (set by service).
    public var grossPrice: UnitMeasurement<Currency>? = nil

    /// This ensures that the service-settable properties are null.
    public mutating func resetInternalProperties() {
        tax = UnitTax()
        netPrice = nil
        grossPrice = nil
    }

    /// Initialize tax data (if it's not been done already)
    /// and set the tax category for this unit.
    public mutating func setTax(category: String? = nil) {
        if tax == nil {
            tax = UnitTax()
        }

        tax!.category = category
    }

    /// Set the tax-related properties using the given `TaxRate`
    ///
    /// NOTE: This requires the `tax` and `netPrice` to be set for this unit.
    /// If this item belongs to a category, then it should be set in the `tax` property.
    public mutating func setPrices(using taxRate: TaxRate) {
        let currency = netPrice!.unit
        var rate = taxRate.general
        if let category = tax!.category {
            if let r = taxRate.categories[category] {
                rate = r
            }
        }

        tax!.rate = rate
        let unitTax = rate * 0.01 * netPrice!.value
        tax!.total = UnitMeasurement(value: unitTax, unit: currency)
        let unitGross = netPrice!.value + unitTax
        grossPrice = UnitMeasurement(value: unitGross, unit: currency)
    }

    public init(product: P, quantity: UInt8) {
        self.product = product
        self.quantity = quantity
    }
}
