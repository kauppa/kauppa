import Foundation

import KauppaCore
import KauppaCouponModel

/// Methods that fetch data from the underlying store.
public protocol CouponQuerying: Querying {
    /// Get a coupon associated with the given ID from store.
    func getCoupon(id: UUID) throws -> Coupon

    /// Get a coupon associated with the given alphanumeric code.
    func getCoupon(code: String) throws -> Coupon
}
