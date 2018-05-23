import Foundation

import Kitura

import KauppaCore
import KauppaAccountsModel
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

var databaseUrl: URL? = nil
var databaseConfig: TLSConfig? = nil

if let url = URL.from(environment: "KAUPPA_DATABASE_URL") {
    print("Database URL has been set. Preparing database client.")
    if let enabled = String.from(environment: "KAUPPPA_DATABASE_TLS_ENABLED"), !enabled.isEmpty {
        guard let caCert = String.from(environment: "KAUPPA_DATABASE_CA_CERT"),
            let clientKey = String.from(environment: "KAUPPA_DATABASE_CLIENT_KEY"),
            let clientCert = String.from(environment: "KAUPPA_DATABASE_CLIENT_CERT")
        else {
            print("KAUPPA_DATABASE_CA_CERT, KAUPPA_DATABASE_CLIENT_KEY and KAUPPA_DATABASE_CLIENT_CERT should be set for enabling database TLS")
            exit(1)
        }

        databaseConfig = TLSConfig(caCertPath: caCert, clientKeyPath: clientKey, clientCertPath: clientCert)
    } else {
        print("TLS not configured for database. Going insecure.")
    }

    databaseUrl = url
} else {
    print("No database provided. Going for in-memory store.")
}

var accountData = Account()
accountData.firstName = "Richard"
accountData.lastName = "Hendricks"
var email = Email("richard.hendricks@piedpiper.com")
email.isVerified = true
accountData.emails.insert(email)
accountData.id = "BAADA555-0B16-B00B-CAFE-BABE8BADF00D".parse()!

let accountsRepository = AccountsRepository(with: AccountsNoOpStore())
let accountsService = AccountsService(with: accountsRepository)
let _ = try! accountsRepository.createAccount(with: accountData)

let taxRepository = TaxRepository(with: TaxNoOpStore())
let taxService = TaxService(with: taxRepository)

let productsStore: ProductsStorable
if let rootUrl = databaseUrl {
    let url = URL(string: "kauppa_products", relativeTo: rootUrl)!
    let database = try! PostgresDatabase(for: url, with: databaseConfig)
    productsStore = try! ProductsStore(with: database)
} else {
    productsStore = ProductsNoOpStore()
}

let productsRepository = ProductsRepository(with: productsStore)
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
