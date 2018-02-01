import Foundation

import KauppaCore

/// Struct with some of the fields from `CouponData` - all are optional.
/// This is used to change one or more fields of `CouponData` in a single
/// update request.
public struct CouponPatch: Mappable {
    /// Disable the coupon.
    public var disable: Bool? = nil
    /// New balance for the coupon.
    public var balance: UnitMeasurement<Currency>? = nil
    /// Set the expiry date for the coupon.
    public var expiresOn: Date? = nil
    /// Add a note for the coupon.
    public var note: String? = nil

    public init() {}
}
