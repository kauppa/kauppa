import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaTaxModel
import KauppaTaxClient

/// Router specific to the tax service.
public class TaxRouter<R: Routing>: ServiceRouter<R, TaxRoutes> {
    let service: TaxServiceCallable

    /// Initializes this router with a `Routing` object and
    /// an `TaxServiceCallable` object.
    public init(with router: R, service: TaxServiceCallable) {
        self.service = service
        super.init(with: router)
    }

    /// Overridden routes for tax service.
    public override func initializeRoutes() {
        add(route: .getTaxRate) { request, response in
            guard let data: Address = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let rate = try self.service.getTaxRate(for: data)
            response.respondJSON(with: rate)
        }

        add(route: .createCountry) { request, response in
            guard let data: CountryData = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let country = try self.service.createCountry(with: data)
            response.respondJSON(with: country)
        }

        add(route: .updateCountry) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidCountryId
            }

            guard let data: CountryPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let country = try self.service.updateCountry(for: id, with: data)
            response.respondJSON(with: country)
        }

        add(route: .deleteCountry) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidCountryId
            }

            try self.service.deleteCountry(for: id)
            response.respondJSON(with: ServiceStatusMessage())
        }

        add(route: .addRegion) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidCountryId
            }

            guard let data: RegionData = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let region = try self.service.addRegion(to: id, using: data)
            response.respondJSON(with: region)
        }

        add(route: .updateRegion) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidRegionId
            }

            guard let data: RegionPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let region = try self.service.updateRegion(for: id, with: data)
            response.respondJSON(with: region)
        }

        add(route: .deleteRegion) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidRegionId
            }

            try self.service.deleteRegion(for: id)
            response.respondJSON(with: ServiceStatusMessage())
        }
    }
}
