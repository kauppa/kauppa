import Foundation

import KauppaCore
import KauppaTaxModel

/// Cart that exists in repository and store.
public struct Cart: Mappable {
    /// Unique identifier for this cart.
    public let id: UUID
    /// Last updated timestamp
    public var updatedAt = Date()
    /// Stuff in the cart
    public var items: [CartUnit] = []
    /// Net price of all items in this cart.
    public var netPrice: UnitMeasurement<Currency>? = nil
    /// Gross price (net price + tax) of items in this cart.
    public var grossPrice: UnitMeasurement<Currency>? = nil
    /// Coupons applied in this cart.
    public var coupons = ArraySet<UUID>()

    public init(withId id: UUID) {
        self.id = id
    }

    /// Reset this cart (called to clear the items once the cart has been checked out)
    public mutating func reset() {
        items = []
        netPrice = nil
        coupons = ArraySet()
    }

    /// Set tax rate for items in the cart using the given `TaxRate`
    /// and calculate the gross price.
    ///
    /// NOTE: This requires the `netPrice` to be set for the cart and the items in it.
    /// If an item belongs to a category, then set the category in its `tax` property.
    public mutating func setPrices(using taxRate: TaxRate) {
        var gross = 0.0
        let currency = netPrice!.unit
        for (i, _) in items.enumerated() {
            items[i].setPrices(using: taxRate)
            gross += items[i].grossPrice!.value
        }

        grossPrice = UnitMeasurement(value: gross, unit: currency)
    }
}
