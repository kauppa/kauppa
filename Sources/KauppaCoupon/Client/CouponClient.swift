import Foundation

import KauppaCore
import KauppaCouponModel

/// HTTP client for the coupon service.
public class CouponServiceClient<C: ClientCallable>: ServiceClient<C, CouponRoutes>, CouponServiceCallable {
    public func createCoupon(with data: CouponData) throws -> Coupon {
        let client = try createClient(for: .createCoupon)
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func getCoupon(for id: UUID) throws -> Coupon {
        let client = try createClient(for: .getCoupon, with: ["id": id])
        return try requestJSON(with: client)
    }

    public func getCoupon(for code: String) throws -> Coupon {
        let client = try createClient(for: .getCoupon, with: ["id": code])
        return try requestJSON(with: client)
    }

    public func updateCoupon(for id: UUID, with data: CouponPatch) throws -> Coupon {
        let client = try createClient(for: .updateCoupon, with: ["id": id])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }
}
