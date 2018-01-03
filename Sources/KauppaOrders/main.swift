import Foundation

import Kitura

import KauppaCore
import KauppaOrdersModel
import KauppaOrdersRepository
import KauppaOrdersService
import KauppaOrdersStore
import KauppaAccountsClient
import KauppaCouponClient
import KauppaShipmentsClient
import KauppaProductsClient
import KauppaTaxClient

class NoOpStore: OrdersStorable {
    public func createOrder(with data: Order) throws -> () {}

    public func getOrder(for id: UUID) throws -> Order {
        throw ServiceError.invalidOrderId
    }

    public func updateOrder(with data: Order) throws -> () {}

    public func deleteOrder(for id: UUID) throws -> () {
        throw ServiceError.invalidOrderId
    }

    public func createRefund(with data: Refund) throws -> () {}
}


let repository = OrdersRepository(with: NoOpStore())

let accountsEndpoint = String.from(environment: "KAUPPA_ACCOUNTS_ENDPOINT")!
let couponsEndpoint = String.from(environment: "KAUPPA_COUPONS_ENDPOINT")!
let productsEndpoint = String.from(environment: "KAUPPA_PRODUCTS_ENDPOINT")!
let shipmentsEndpoint = String.from(environment: "KAUPPA_SHIPMENTS_ENDPOINT")!
let taxEndpoint = String.from(environment: "KAUPPA_TAX_ENDPOINT")!

let accountsClient: AccountsServiceClient<SwiftyRestRequest> = AccountsServiceClient(for: accountsEndpoint)!
let couponClient: CouponServiceClient<SwiftyRestRequest> = CouponServiceClient(for: couponsEndpoint)!
let productsClient: ProductsServiceClient<SwiftyRestRequest> = ProductsServiceClient(for: productsEndpoint)!
let shipmentsClient: ShipmentsServiceClient<SwiftyRestRequest> = ShipmentsServiceClient(for: shipmentsEndpoint)!
let taxClient: TaxServiceClient<SwiftyRestRequest> = TaxServiceClient(for: taxEndpoint)!

let ordersService = OrdersService(with: repository, accountsService: accountsClient,
                                  productsService: productsClient, shippingService: shipmentsClient,
                                  couponService: couponClient, taxService: taxClient)

let router = Router()       // Kitura's router
let ordersRouter = OrdersRouter(with: router, service: ordersService)

let servicePort = Int.from(environment: "KAUPPA_SERVICE_PORT") ?? 8090
print("Listening to requests on port \(servicePort)")

// FIXME: This should be managed by the controller
Kitura.addHTTPServer(onPort: servicePort, with: router)

Kitura.run()
