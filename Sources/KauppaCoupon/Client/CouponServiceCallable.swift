import Foundation

import KauppaCouponModel

public protocol CouponServiceCallable {
    /// Create a coupon with the given data.
    ///
    /// - Parameters:
    ///   - with: `CouponData` required for creating a coupon.
    /// - Returns: A `Coupon` with a valid alphanumeric code.
    /// - Throws: `CouponError`
    func createCoupon(with data: CouponData) throws -> Coupon

    /// Get the coupon corresponding to an ID.
    ///
    /// - Parameters:
    ///   - id: `UUID` of this coupon.
    /// - Returns: The `Coupon` (if it exists)
    /// - Throws: `CouponError` (if it's non-existent)
    func getCoupon(id: UUID) throws -> Coupon

    /// Get the coupon for the given alphanumeric code (if any).
    ///
    /// - Parameters:
    ///   - forCode: The unique alphanumeric code of a coupon.
    /// - Returns: The `Coupon` (if it exists)
    /// - Throws: `CouponError` (if it's non-existent)
    func getCoupon(forCode code: String) throws -> Coupon

    /// Update a coupon with the given patch.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the coupon. **This is not the coupon's code!**
    ///   - data: The `CouponPatch` data for updating the corresponding coupon.
    /// - Returns: The `Coupon` (if it's been successfully updated)
    /// - Throws: `CouponError`
    func updateCoupon(id: UUID, data: CouponPatch) throws -> Coupon
}
