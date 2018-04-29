import Foundation

import Kitura

import KauppaCore
import KauppaTaxRepository
import KauppaTaxService
import KauppaTaxStore

let repository = TaxRepository(with: TaxNoOpStore())
let taxService = TaxService(with: repository)

let router = Router()       // Kitura's router
let serviceRouter = TaxRouter(with: router, service: taxService)

let servicePort = Int.from(environment: "KAUPPA_SERVICE_PORT") ?? 8090
print("Listening to requests on port \(servicePort)")

// FIXME: This should be managed by the controller
Kitura.addHTTPServer(onPort: servicePort, with: router)

Kitura.run()
