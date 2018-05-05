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
    public var netPrice: Price? = nil
    /// The price of this unit with tax (set by service).
    public var grossPrice: Price? = nil

    /// This ensures that the service-settable properties are null.
    public mutating func resetInternalProperties() {
        tax = UnitTax()
        netPrice = nil
        grossPrice = nil
    }

    /// Initialize tax data (if it's not been done already)
    /// and set the tax category for this unit.
    ///
    /// - Parameters:
    ///   - using: The category (or) tax class for this cart unit as a string.
    public mutating func setTax(using category: String? = nil) {
        if tax == nil {
            tax = UnitTax()
        }

        tax!.category = category
    }

    /// Set the tax-related properties using the given `TaxRate`
    ///
    /// - Parameters:
    ///   - using: The `TaxRate` to be used for calculating the prices.
    ///
    /// NOTE: This requires the `tax` and `netPrice` to be set for this unit.
    /// If this item belongs to a category, then it should be set in the `tax` property.
    public mutating func setPrices(using taxRate: TaxRate) {
        var rate = taxRate.general
        if let category = tax!.category {
            if let r = taxRate.categories[category] {
                rate = r
            }
        }

        tax!.rate = rate
        let unitTax = rate * 0.01 * netPrice!.value
        tax!.total = Price(unitTax)
        let unitGross = netPrice!.value + unitTax
        grossPrice = Price(unitGross)
    }

    /// Initialize this `CartUnit` with a product and the quantity of items.
    ///
    /// - Parameters:
    ///   - for: An object which represents the product.
    ///   - with: The quantity of that product.
    public init(for product: P, with quantity: UInt8) {
        self.product = product
        self.quantity = quantity
    }
}
