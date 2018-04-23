import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaTaxModel

public class TaxServiceClient<C: ClientCallable>: ServiceClient<C, TaxRoutes>, TaxServiceCallable {
    public func getTaxRate(for address: Address) throws -> TaxRate {
        let client = try createClient(for: .getTaxRate)
        try client.setJSON(using: address)
        return try requestJSON(with: client)
    }

    public func createCountry(with data: CountryData) throws -> Country {
        let client = try createClient(for: .createCountry)
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func updateCountry(for id: UUID, with data: CountryPatch) throws -> Country {
        let client = try createClient(for: .updateCountry)
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func deleteCountry(for id: UUID) throws -> () {
        let client = try createClient(for: .deleteCountry)
        let _: ServiceStatusMessage = try requestJSON(with: client)
    }

    public func addRegion(to id: UUID, using data: RegionData) throws -> Region {
        let client = try createClient(for: .addRegion)
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func updateRegion(for id: UUID, with data: RegionPatch) throws -> Region {
        let client = try createClient(for: .updateRegion)
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func deleteRegion(for id: UUID) throws -> () {
        let client = try createClient(for: .updateRegion)
        let _: ServiceStatusMessage = try requestJSON(with: client)
    }
}
