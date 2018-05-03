import Foundation

import KauppaCore
import KauppaCouponModel
import KauppaCouponClient

/// Router specific to the coupon service.
public class CouponRouter<R: Routing>: ServiceRouter<R, CouponRoutes> {
    let service: CouponServiceCallable

    /// Initializes this router with a `Routing` object and a
    /// `CouponServiceCallable` object.
    public init(with router: R, service: CouponServiceCallable) {
        self.service = service
        super.init(with: router)
    }

    /// Overridden routes for coupon service.
    public override func initializeRoutes() {
        add(route: .createCoupon) { request, response in
            guard let data: CouponData = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let coupon = try self.service.createCoupon(with: data)
            try response.respondJSON(with: coupon)
        }

        add(route: .getCoupon) { request, response in
            guard let couponId: UUID = request.getParameter(for: "id") else {
                guard let code: String = request.getParameter(for: "id") else {
                    throw ServiceError.invalidCouponCode
                }

                let coupon = try self.service.getCoupon(for: code)
                try response.respondJSON(with: coupon)
                return
            }

            let coupon = try self.service.getCoupon(for: couponId)
            try response.respondJSON(with: coupon)
        }

        add(route: .updateCoupon) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidCouponId
            }

            guard let data: CouponPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let coupon = try self.service.updateCoupon(for: id, with: data)
            try response.respondJSON(with: coupon)
        }
    }
}
