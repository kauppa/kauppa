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
    public func getTaxRate(forAddress address: Address) throws -> TaxRate {
        // FIXME: This could be done efficiently?
        // Get the country first. This should match a valid country in the store.
        let country = try repository.getCountry(name: address.country)
        var taxRate = country.taxRate
        // Try getting the province. If it matches, override the rates in country with
        // the values from province.
        if let province = try? repository.getRegion(name: address.province,
                                                    forCountry: address.country)
        {
            taxRate.applyOverrideFrom(province.taxRate)
        }

        if let city = try? repository.getRegion(name: address.city, forCountry: address.country) {
            taxRate.applyOverrideFrom(city.taxRate)
        }

        return taxRate
    }

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

    public func updateRegion(id: UUID, with data: RegionPatch) throws -> Region {
        var region = try repository.getRegion(id: id)

        if let name = data.name {
            region.name = name
        }

        if let rate = data.taxRate {
            region.taxRate = rate
        }

        if let countryId = data.countryId {
            let _ = try repository.getCountry(id: countryId)
            region.countryId = countryId
        }

        if let kind = data.kind {
            region.kind = kind
        }

        try region.validate()
        return try repository.updateRegion(with: region)
    }

    public func deleteRegion(id: UUID) throws -> () {
        return try repository.deleteRegion(id: id)
    }
}
