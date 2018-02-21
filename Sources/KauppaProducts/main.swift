import Foundation

import Kitura

import KauppaCore
import KauppaProductsModel
import KauppaProductsRepository
import KauppaProductsService
import KauppaProductsStore
import KauppaTaxClient

let repository = ProductsRepository(with: ProductsNoOpStore())
let taxEndpoint = String.from(environment: "KAUPPA_TAX_ENDPOINT")!
let taxClient: TaxServiceClient<SwiftyRestRequest> = TaxServiceClient(for: taxEndpoint)!
let productsService = ProductsService(with: repository, taxService: taxClient)

let router = Router()       // Kitura's router
let serviceRouter = ProductsRouter(with: router, service: productsService)

let servicePort = Int.from(environment: "KAUPPA_SERVICE_PORT") ?? 8090
print("Listening to requests on port \(servicePort)")

// FIXME: This should be managed by the controller
Kitura.addHTTPServer(onPort: servicePort, with: router)

Kitura.run()
