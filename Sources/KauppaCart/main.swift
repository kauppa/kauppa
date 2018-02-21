import Foundation

import Kitura

import KauppaCore
import KauppaCartRepository
import KauppaCartService
import KauppaCartStore
import KauppaAccountsClient
import KauppaCouponClient
import KauppaOrdersClient
import KauppaProductsClient
import KauppaTaxClient

let repository = CartRepository(with: CartNoOpStore())

let accountsEndpoint = String.from(environment: "KAUPPA_ACCOUNTS_ENDPOINT")!
let couponsEndpoint = String.from(environment: "KAUPPA_COUPONS_ENDPOINT")!
let ordersEndpoint = String.from(environment: "KAUPPA_ORDERS_ENDPOINT")!
let productsEndpoint = String.from(environment: "KAUPPA_PRODUCTS_ENDPOINT")!
let taxEndpoint = String.from(environment: "KAUPPA_TAX_ENDPOINT")!

let accountsClient: AccountsServiceClient<SwiftyRestRequest> = AccountsServiceClient(for: accountsEndpoint)!
let couponClient: CouponServiceClient<SwiftyRestRequest> = CouponServiceClient(for: couponsEndpoint)!
let ordersClient: OrdersServiceClient<SwiftyRestRequest> = OrdersServiceClient(for: ordersEndpoint)!
let productsClient: ProductsServiceClient<SwiftyRestRequest> = ProductsServiceClient(for: productsEndpoint)!
let taxClient: TaxServiceClient<SwiftyRestRequest> = TaxServiceClient(for: taxEndpoint)!

let cartService = CartService(with: repository, productsService: productsClient,
                              accountsService: accountsClient, couponService: couponClient,
                              ordersService: ordersClient, taxService: taxClient)

let router = Router()       // Kitura's router
let serviceRouter = CartRouter(with: router, service: cartService)

let servicePort = Int.from(environment: "KAUPPA_SERVICE_PORT") ?? 8090
print("Listening to requests on port \(servicePort)")

// FIXME: This should be managed by the controller
Kitura.addHTTPServer(onPort: servicePort, with: router)

Kitura.run()
