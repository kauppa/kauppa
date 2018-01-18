import Foundation

import KauppaCore
import KauppaCouponClient
import KauppaCouponModel
import KauppaCouponRepository

/// Public API for creation/modification of coupons.
public class CouponService {
    let repository: CouponRepository

    /// Initializes a new `CouponService` instance with a repository.
    public init(withRepository repository: CouponRepository) {
        self.repository = repository
    }
}

// NOTE: See the actual protocol in `KauppaCouponClient` for exact usage.
extension CouponService: CouponServiceCallable {
    public func createCoupon(with data: CouponData) throws -> Coupon {
        var couponData = data
        try couponData.validate()
        return try repository.createCoupon(data: couponData)
    }

    public func getCoupon(id: UUID) throws -> Coupon {
        var coupon = try repository.getCoupon(forId: id)
        coupon.data.hideCode()
        return coupon
    }

    public func getCoupon(forCode code: String) throws -> Coupon {
        var coupon = try repository.getCoupon(forCode: code)
        coupon.data.hideCode()
        return coupon
    }

    public func updateCoupon(id: UUID, data: CouponPatch) throws -> Coupon {
        var couponData = try repository.getCouponData(forId: id)

        if data.disable ?? false {
            couponData.disabledOn = Date()
        }

        if let value = data.balance {
            couponData.balance = value
        }

        if let date = data.expiresOn {
            couponData.expiresOn = date
        }

        if let note = data.note {
            couponData.note = note
        }

        try couponData.validate()
        var coupon = try repository.updateCouponData(id: id, data: couponData)
        coupon.data.hideCode()
        return coupon
    }
}
