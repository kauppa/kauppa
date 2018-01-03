import Foundation

import Kitura

import KauppaCore
import KauppaCouponModel
import KauppaCouponRepository
import KauppaCouponService
import KauppaCouponStore

class NoOpStore: CouponStorable {
    public func createCoupon(with data: Coupon) throws -> () {}

    public func getCoupon(for code: String) throws -> Coupon {
        throw ServiceError.invalidCouponCode
    }

    public func getCoupon(for id: UUID) throws -> Coupon {
        throw ServiceError.invalidCouponId
    }

    public func updateCoupon(with data: Coupon) throws -> () {}
}


let repository = CouponRepository(with: NoOpStore())
let couponService = CouponService(with: repository)

let router = Router()       // Kitura's router
let serviceRouter = CouponRouter(with: router, service: couponService)

let servicePort = Int.from(environment: "KAUPPA_SERVICE_PORT") ?? 8090
print("Listening to requests on port \(servicePort)")

// FIXME: This should be managed by the controller
Kitura.addHTTPServer(onPort: servicePort, with: router)

Kitura.run()
