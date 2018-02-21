import Foundation

import Kitura

import KauppaCore
import KauppaCouponModel
import KauppaCouponRepository
import KauppaCouponService
import KauppaCouponStore

let repository = CouponRepository(with: CouponNoOpStore())
let couponService = CouponService(with: repository)

let router = Router()       // Kitura's router
let serviceRouter = CouponRouter(with: router, service: couponService)

let servicePort = Int.from(environment: "KAUPPA_SERVICE_PORT") ?? 8090
print("Listening to requests on port \(servicePort)")

// FIXME: This should be managed by the controller
Kitura.addHTTPServer(onPort: servicePort, with: router)

Kitura.run()
