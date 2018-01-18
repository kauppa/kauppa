import Foundation

import KauppaAccountsModel
import KauppaTaxClient
import KauppaTaxModel
import KauppaTaxRepository

/// Public API for calculating various taxes for an order.
public class TaxService {
    let repository: TaxRepository

    /// Initializes a new `TaxService` instance with a repository.
    public init(withRepository repository: TaxRepository) {
        self.repository = repository
    }
}

// NOTE: See the actual protocol in `KauppaTaxClient` for exact usage.
extension TaxService: TaxServiceCallable {
    public func createCountry(with data: CountryData) throws -> Country {
        let country = Country(name: data.name, taxRate: data.taxRate)
        try country.validate()
        try repository.createCountry(with: country)
        return country
    }

    public func updateCountry(id: UUID, with data: CountryPatch) throws -> Country {
        var country = try repository.getCountry(id: id)

        if let name = data.name {
            country.name = name
        }

        if let rate = data.taxRate {
            country.taxRate = rate
        }

        try country.validate()
        return try repository.updateCountry(with: country)
    }

    public func deleteCountry(id: UUID) throws -> () {
        try repository.deleteCountry(id: id)
    }

    public func addRegion(toCountry id: UUID, data: RegionData) throws -> Region {
        let _ = try repository.getCountry(id: id)
        let region = Region(name: data.name, taxRate: data.taxRate, kind: data.kind, country: id)
        try region.validate()
        try repository.createRegion(with: region)
        return region
    }
}
