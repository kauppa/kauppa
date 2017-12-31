import KauppaCore

/// Coupon data passed to the cart.
public struct CartCoupon: Mappable {
    /// Unique code for the coupon (different from its UUID).
    public let code: String
}
