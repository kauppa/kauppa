import Foundation

import KauppaCore
import KauppaTaxModel

/// Cart that exists in repository and store.
public struct Cart: Mappable {
    /// Unique identifier for this cart.
    public var id: UUID?
    /// Last updated timestamp
    public var updatedAt: Date? = Date()
    /// Stuff in the cart
    public var items: [CartUnit] = []
    /// Currency used in this cart.
    public var currency: Currency? = nil
    /// Net price of all items in this cart.
    public var netPrice: Price? = nil
    /// Gross price (net price + tax) of items in this cart.
    public var grossPrice: Price? = nil
    /// Coupons applied in this cart.
    public var coupons: ArraySet<UUID>? = nil
    /// Checkout data for this cart. This should be set before
    /// placing the order.
    public var checkoutData: CheckoutData? = nil

    /// Initialize this cart with an ID.
    ///
    /// - Parameters:
    ///   - with: The `UUID` of this cart.
    public init(with id: UUID) {
        self.id = id
    }

    /// Reset this cart (called to clear the items once the cart has been checked out).
    public mutating func reset() {
        updatedAt = Date()
        items = []
        currency = nil
        netPrice = nil
        grossPrice = nil
        coupons = nil
        checkoutData = nil
    }

    /// Set tax rate for items in the cart using the given `TaxRate`
    /// and calculate the gross price.
    ///
    /// - Parameters:
    ///   - using: The `TaxRate` to be used for calculating the gross prices.
    ///
    /// NOTE: This requires the `netPrice` to be set for the cart and the items in it.
    /// If an item belongs to a category, then the category should be set in its `tax` property.
    /// The `tax` property of the items should've also been initialized at this point.
    public mutating func setPrices(using taxRate: TaxRate) {
        var gross = Price()
        for (i, _) in items.enumerated() {
            items[i].setPrices(using: taxRate)
            gross += items[i].grossPrice!
        }

        grossPrice = gross
    }
}
