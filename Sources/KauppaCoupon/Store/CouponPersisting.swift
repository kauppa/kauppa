import Foundation

import KauppaCore
import KauppaCouponModel

/// Methods that mutate the underlying store with information.
public protocol CouponPersisting: Persisting {
    /// Create a coupon with data from the repository.
    ///
    /// - Parameters:
    ///   - with: The `Coupon` object from repository.
    /// - Throws: `ServiceError` on failure.
    func createCoupon(with data: Coupon) throws -> ()

    /// Update a coupon with data from the repository.
    ///
    /// - Parameters:
    ///   - with: The `Coupon` object from repository.
    /// - Throws: `ServiceError` on failure.
    func updateCoupon(with data: Coupon) throws -> ()
}
