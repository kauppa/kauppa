import Foundation

import KauppaCore
import KauppaCouponModel

/// Methods that mutate the underlying store with information.
public protocol CouponPersisting: Persisting {
    /// Create a coupon with data from the repository.
    func createCoupon(with data: Coupon) throws -> ()

    /// Update a coupon with data from the repository.
    func updateCoupon(with data: Coupon) throws -> ()
}
