import Foundation

import Kitura

import KauppaCore
import KauppaShipmentsRepository
import KauppaShipmentsService
import KauppaShipmentsStore
import KauppaOrdersClient

let repository = ShipmentsRepository(with: ShipmentsNoOpStore())
let ordersEndpoint = String.from(environment: "KAUPPA_ORDERS_ENDPOINT")!
let ordersClient: OrdersServiceClient<SwiftyRestRequest> = OrdersServiceClient(for: ordersEndpoint)!
let shippingService = ShipmentsService(with: repository, ordersService: ordersClient)

let router = Router()       // Kitura's router
let serviceRouter = ShipmentsRouter(with: router, service: shippingService)

let servicePort = Int.from(environment: "KAUPPA_SERVICE_PORT") ?? 8090
print("Listening to requests on port \(servicePort)")

// FIXME: This should be managed by the controller
Kitura.addHTTPServer(onPort: servicePort, with: router)

Kitura.run()
