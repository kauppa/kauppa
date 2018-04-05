import Foundation

@testable import KauppaCouponModel
@testable import KauppaCouponStore

public class TestStore: CouponStorable {
    public var coupons = [UUID: Coupon]()
    public var codes = [String: UUID]()

    // Variables to indicate the count of function calls.
    public var createCalled = false
    public var getCalled = false
    public var updateCalled = false
    public var codeGetCalled = false

    public func createCoupon(with data: Coupon) throws -> () {
        createCalled = true
        coupons[data.id] = data
    }

    public func getCoupon(for code: String) throws -> Coupon {
        codeGetCalled = true
        guard let id = codes[code] else {
            throw CouponError.invalidCode
        }

        return try getCoupon(for: id)
    }

    public func getCoupon(for id: UUID) throws -> Coupon {
        getCalled = true
        guard let coupon = coupons[id] else {
            throw CouponError.invalidCouponId
        }

        return coupon
    }

    public func updateCoupon(with data: Coupon) throws -> () {
        updateCalled = true
        coupons[data.id] = data
    }
}
