import Foundation

import Kitura

import KauppaCore
import KauppaTaxModel
import KauppaTaxRepository
import KauppaTaxService
import KauppaTaxStore

class NoOpStore: TaxStorable {
    public func createCountry(with data: Country) throws -> () {}

    public func getCountry(name: String) throws -> Country {
        throw ServiceError.noMatchingCountry
    }

    public func getCountry(id: UUID) throws -> Country {
        throw ServiceError.invalidCountryId
    }

    public func updateCountry(with data: Country) throws -> () {}

    public func deleteCountry(for id: UUID) throws -> () {}

    public func createRegion(with data: Region) throws -> () {}

    public func getRegion(id: UUID) throws -> Region {
        throw ServiceError.invalidRegionId
    }

    public func getRegion(name: String, for countryName: String) throws -> Region {
        throw ServiceError.noMatchingRegion
    }

    public func updateRegion(with data: Region) throws -> () {}

    public func deleteRegion(for id: UUID) throws -> () {}
}


let repository = TaxRepository(with: NoOpStore())
let taxService = TaxService(with: repository)

let router = Router()       // Kitura's router
let serviceRouter = TaxRouter(with: router, service: taxService)

let servicePort = Int.from(environment: "KAUPPA_SERVICE_PORT") ?? 8090
print("Listening to requests on port \(servicePort)")

// FIXME: This should be managed by the controller
Kitura.addHTTPServer(onPort: servicePort, with: router)

Kitura.run()
