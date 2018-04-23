import Foundation

import Kitura

import KauppaCore
import KauppaShipmentsModel
import KauppaShipmentsRepository
import KauppaShipmentsService
import KauppaShipmentsStore
import KauppaOrdersClient

class NoOpStore: ShipmentsStorable {
    public func createShipment(with data: Shipment) throws -> () {}

    public func updateShipment(with data: Shipment) throws -> () {}

    public func getShipment(for id: UUID) throws -> Shipment {
        throw ServiceError.invalidShipmentId
    }
}


let repository = ShipmentsRepository(with: NoOpStore())
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
