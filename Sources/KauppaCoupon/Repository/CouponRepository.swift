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

    public init(withStore store: CouponStorable) {
        self.store = store
    }

    /// Create a coupon with data from the service.
    public func createCoupon(data: CouponData) throws -> Coupon {
        let coupon = Coupon(with: data)
        coupons[coupon.id] = coupon
        // safe to unwrap because service ensures that the coupon has valid code
        codes[coupon.data.code!] = coupon.id
        try store.createCoupon(data: coupon)
        return coupon
    }

    /// Fetch the coupon from the repository for a given code if any,
    /// or get it from the store.
    public func getCoupon(forCode code: String) throws -> Coupon {
        guard let id = codes[code] else {
            let coupon = try store.getCoupon(code: code)
            codes[coupon.data.code!] = coupon.id
            return coupon
        }

        return try getCoupon(forId: id)
    }

    /// Fetch the coupon from repository if available, or get it from store.
    public func getCoupon(forId id: UUID) throws -> Coupon {
        guard let coupon = coupons[id] else {
            let coupon = try store.getCoupon(id: id)
            coupons[id] = coupon
            return coupon
        }

        return coupon
    }

    /// Get the user-supplied data for a coupon.
    public func getCouponData(forId id: UUID) throws -> CouponData {
        let coupon = try getCoupon(forId: id)
        return coupon.data
    }

    /// Update a coupon with data from the service.
    public func updateCouponData(id: UUID, data: CouponData) throws -> Coupon {
        var coupon = try getCoupon(forId: id)
        coupon.updatedAt = Date()
        coupons[id] = coupon
        coupon.data = data
        try store.updateCoupon(data: coupon)
        return coupon
    }
}
