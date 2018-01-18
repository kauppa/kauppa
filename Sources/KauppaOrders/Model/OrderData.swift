import Foundation

import KauppaAccountsModel
import KauppaCore

/// Input data for placing an order
public struct OrderData: Mappable {
    /// Shipping address
    public let shippingAddress: Address
    /// Billing address (if any)
    public var billingAddress: Address
    /// ID of the user who placed this order.
    public let placedBy: UUID
    /// List of product IDs and their quantity (as an order unit).
    public let products: [OrderUnit]
    /// List of UUIDs of the coupons applied by the user.
    public var appliedCoupons = ArraySet<UUID>()

    public init(shippingAddress: Address, billingAddress: Address? = nil,
                placedBy id: UUID, products: [OrderUnit])
    {
        self.shippingAddress = shippingAddress
        if let address = billingAddress {
            self.billingAddress = address
        } else {
            self.billingAddress = shippingAddress
        }

        self.placedBy = id
        self.products = products
    }
}
