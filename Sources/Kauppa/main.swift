import Foundation

import Kitura

import KauppaCore
import KauppaAccountsRepository
import KauppaAccountsService
import KauppaAccountsStore
import KauppaCartRepository
import KauppaCartService
import KauppaCartStore
import KauppaCouponRepository
import KauppaCouponService
import KauppaCouponStore
import KauppaOrdersRepository
import KauppaOrdersService
import KauppaOrdersStore
import KauppaProductsRepository
import KauppaProductsService
import KauppaProductsStore
import KauppaShipmentsRepository
import KauppaShipmentsService
import KauppaShipmentsStore
import KauppaTaxRepository
import KauppaTaxService
import KauppaTaxStore

let accountsRepository = AccountsRepository(with: AccountsNoOpStore())
let accountsService = AccountsService(with: accountsRepository)

let taxRepository = TaxRepository(with: TaxNoOpStore())
let taxService = TaxService(with: taxRepository)

let productsRepository = ProductsRepository(with: ProductsNoOpStore())
let productsService = ProductsService(with: productsRepository, taxService: taxService)

let couponRepository = CouponRepository(with: CouponNoOpStore())
let couponService = CouponService(with: couponRepository)

let ordersRepository = OrdersRepository(with: OrdersNoOpStore())
let ordersService = OrdersService(with: ordersRepository, accountsService: accountsService,
                                  productsService: productsService, shippingService: nil,
                                  couponService: couponService, taxService: taxService)

let shipmentsRepository = ShipmentsRepository(with: ShipmentsNoOpStore())
let shippingService = ShipmentsService(with: shipmentsRepository, ordersService: ordersService)
ordersService.shippingService = shippingService

let cartRepository = CartRepository(with: CartNoOpStore())
let cartService = CartService(with: cartRepository, productsService: productsService,
                              accountsService: accountsService, couponService: couponService,
                              ordersService: ordersService, taxService: taxService)

let router = Router()
let _ = AccountsRouter(with: router, service: accountsService)
let _ = CartRouter(with: router, service: cartService)
let _ = CouponRouter(with: router, service: couponService)
let _ = OrdersRouter(with: router, service: ordersService)
let _ = ProductsRouter(with: router, service: productsService)
let _ = ShipmentsRouter(with: router, service: shippingService)
let _ = TaxRouter(with: router, service: taxService)

let servicePort = Int.from(environment: "KAUPPA_SERVICE_PORT") ?? 8090
print("Listening to requests on port \(servicePort)")

// FIXME: This should be managed by the controller
Kitura.addHTTPServer(onPort: servicePort, with: router)

Kitura.run()
