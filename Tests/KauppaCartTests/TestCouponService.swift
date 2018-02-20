import Foundation
import XCTest

import KauppaCouponClient
import KauppaCouponModel

public class TestCouponService: CouponServiceCallable {
    var coupons = [UUID: Coupon]()

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

    public func getCoupon(for code: String) throws -> Coupon {
        for (_, coupon) in coupons {
            if coupon.data.code == code {
                return coupon
            }
        }

        throw CouponError.invalidCouponCode
    }

    // NOTE: Not meant to be called by cart
    public func updateCoupon(for id: UUID, with data: CouponPatch) throws -> Coupon {
        throw CouponError.invalidCouponId
    }
}
