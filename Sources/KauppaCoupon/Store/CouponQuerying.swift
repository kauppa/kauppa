import Foundation

import KauppaCore
import KauppaCouponModel

/// Methods that fetch data from the underlying store.
public protocol CouponQuerying: Querying {
    /// Get a coupon associated with the given ID from store.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the coupon.
    /// - Returns: `Coupon` object (if it exists)
    /// - Throws: `CouponError` on failure.
    func getCoupon(for id: UUID) throws -> Coupon

    /// Get a coupon associated with the given alphanumeric code.
    ///
    /// - Parameters:
    ///   - for: The unique 16-char alphanumeric code of the coupon.
    /// - Returns: `Coupon` object (if it exists)
    /// - Throws: `CouponError` on failure.
    func getCoupon(for code: String) throws -> Coupon
}
