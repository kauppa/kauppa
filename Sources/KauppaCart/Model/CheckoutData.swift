import KauppaCore

/// Data required for placing an order from the cart.
public struct CheckoutData: Mappable {
    /// Shipping address for this order (represents the address index in `AccountData`
    /// which also means that in order to checkout, you need to add/use the address
    /// to the user account).
    public var shippingAddressAt: Int = 0
    /// Billing address for this order (if null, shipping address is used)
    public var billingAddressAt: Int? = nil
}
