import Foundation

import KauppaCore
import KauppaCouponModel

/// A no-op store for coupons which doesn't support data persistence/querying.
/// This way, the repository takes care of all service requests by providing
/// in-memory data.
public class CouponNoOpStore: CouponStorable {
    public init() {}

    public func createCoupon(with data: Coupon) throws -> () {}

    public func getCoupon(for code: String) throws -> Coupon {
        throw ServiceError.invalidCouponCode
    }

    public func getCoupon(for id: UUID) throws -> Coupon {
        throw ServiceError.invalidCouponId
    }

    public func updateCoupon(with data: Coupon) throws -> () {}
}
