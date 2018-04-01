import Foundation

import KauppaCore
import KauppaCouponModel
import KauppaCouponStore

/// Manages the retrieval and persistance of coupon data from store.
public class CouponRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var coupons = [UUID: Coupon]()
    var codes = [String: UUID]()
    var store: CouponStorable

    public init(with store: CouponStorable) {
        self.store = store
    }

    /// Create a coupon with data from the service.
    public func createCoupon(with data: CouponData) throws -> Coupon {
        let coupon = Coupon(with: data)
        coupons[coupon.id] = coupon
        // safe to unwrap because service ensures that the coupon has valid code
        codes[coupon.data.code!] = coupon.id
        try store.createCoupon(with: coupon)
        return coupon
    }

    /// Fetch the coupon from the repository for a given code if any,
    /// or get it from the store.
    public func getCoupon(for code: String) throws -> Coupon {
        guard let id = codes[code] else {
            let coupon = try store.getCoupon(for: code)
            codes[coupon.data.code!] = coupon.id
            return coupon
        }

        return try getCoupon(for: id)
    }

    /// Fetch the coupon from repository if available, or get it from store.
    public func getCoupon(for id: UUID) throws -> Coupon {
        guard let coupon = coupons[id] else {
            let coupon = try store.getCoupon(for: id)
            coupons[id] = coupon
            return coupon
        }

        return coupon
    }

    /// Get the user-supplied data for a coupon.
    public func getCouponData(for id: UUID) throws -> CouponData {
        let coupon = try getCoupon(for: id)
        return coupon.data
    }

    /// Update a coupon with data from the service.
    public func updateCoupon(for id: UUID, with data: CouponData) throws -> Coupon {
        var coupon = try getCoupon(for: id)
        coupon.updatedAt = Date()
        coupons[id] = coupon
        coupon.data = data
        try store.updateCoupon(with: coupon)
        return coupon
    }
}
