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

    public func createCoupon(data: Coupon) throws -> () {
        createCalled = true
        coupons[data.id] = data
    }

    public func getCoupon(code: String) throws -> Coupon {
        codeGetCalled = true
        guard let id = codes[code] else {
            throw CouponError.invalidCode
        }

        return try getCoupon(id: id)
    }

    public func getCoupon(id: UUID) throws -> Coupon {
        getCalled = true
        guard let coupon = coupons[id] else {
            throw CouponError.invalidCouponId
        }

        return coupon
    }

    public func updateCoupon(data: Coupon) throws -> () {
        updateCalled = true
        coupons[data.id] = data
    }
}
