import Foundation

import KauppaCore
import KauppaTaxModel

/// An order unit where the product is represented by its UUID.
public typealias OrderUnit = GenericOrderUnit<UUID>

/// Represents a product in order (along with the quantity required).
public struct GenericOrderUnit<P: Mappable>: Mappable {
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
    /// Status of this order unit.
    public var status: OrderUnitStatus? = nil

    /// Initialize this unit with a product and quantity.
    ///
    /// - Parameters:
    ///   - for: The product represented by this unit.
    ///   - with: The quantity of the product item.
    public init(for product: P, with quantity: UInt8) {
        self.product = product
        self.quantity = quantity
    }

    /// `nil` indicates that none of the items in this unit
    /// has been fulfilled. It's either not delivered to the customer
    /// or the entire unit has been returned by the customer.
    /// The other case, however represents that some (or all) of the
    /// items have reached the customer.
    public var hasFulfillment: Bool {
        return self.status != nil
    }

    /// Resets the service-settable properties in this object.
    public mutating func resetInternalProperties() {
        tax = UnitTax()
        netPrice = nil
        grossPrice = nil
        status = nil
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
        tax!.total = Price(rate * 0.01 * netPrice!.value)
        // If the unit is inclusive of tax, then gross price is same as net price.
        grossPrice = (tax!.inclusive) ? netPrice! : netPrice! + tax!.total
    }

    /// Number of items that have been fulfilled and hasn't been scheduled for pickup.
    public func untouchedItems() -> UInt8 {
        if let unitStatus = status {
            return unitStatus.fulfilledQuantity - unitStatus.pickupQuantity
        }

        return 0
    }
}
