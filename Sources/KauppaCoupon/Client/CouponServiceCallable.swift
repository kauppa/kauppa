import Foundation

import KauppaCouponModel

public protocol CouponServiceCallable {
    /// Create a coupon with the given data.
    ///
    /// - Parameters:
    ///   - with: `CouponData` required for creating a coupon.
    /// - Returns: A `Coupon` with a valid alphanumeric code.
    /// - Throws: `ServiceError`
    func createCoupon(with data: CouponData) throws -> Coupon

    /// Get the coupon corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: `UUID` of this coupon.
    /// - Returns: The `Coupon` (if it exists)
    /// - Throws: `ServiceError` (if it's non-existent)
    func getCoupon(for id: UUID) throws -> Coupon

    /// Get the coupon for the given alphanumeric code (if any).
    ///
    /// - Parameters:
    ///   - for: The unique alphanumeric code of a coupon.
    /// - Returns: The `Coupon` (if it exists)
    /// - Throws: `ServiceError` (if it's non-existent)
    func getCoupon(for code: String) throws -> Coupon

    /// Update a coupon with the given patch.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the coupon. **This is not the coupon's code!**
    ///   - with: The `CouponPatch` data for updating the corresponding coupon.
    /// - Returns: The `Coupon` (if it's been successfully updated)
    /// - Throws: `ServiceError`
    func updateCoupon(for id: UUID, with data: CouponPatch) throws -> Coupon
}
