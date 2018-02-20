import Foundation
import XCTest

import KauppaCouponClient
import KauppaCouponModel

public typealias CouponCallback = (CouponPatch) -> Void

public class TestCouponService: CouponServiceCallable {
    var coupons = [UUID: Coupon]()
    var callbacks = [UUID: CouponCallback]()

    public func createCoupon(with data: CouponData) throws -> Coupon {
        let coupon = Coupon(with: data)
        coupons[coupon.id] = coupon
        return coupon
    }

    public func getCoupon(for id: UUID) throws -> Coupon {
        guard let coupon = coupons[id] else {
            throw CouponError.invalidCouponId
        }

        return coupon
    }

    // NOTE: Not meant to be called by orders
    public func getCoupon(for code: String) throws -> Coupon {
        throw CouponError.invalidCouponCode
    }

    public func updateCoupon(for id: UUID, with data: CouponPatch) throws -> Coupon {
        if let callback = callbacks[id] {
            callback(data)
        }

        return try getCoupon(for: id)       // This is just a stub
    }
}
