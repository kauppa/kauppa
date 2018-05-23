import Foundation

import Loki

import KauppaCore
import KauppaAccountsModel
import KauppaTaxClient
import KauppaTaxModel
import KauppaTaxRepository

/// Public API for calculating various taxes for an order.
public class TaxService {
    let repository: TaxRepository

    /// Initializes a new `TaxService` instance with a repository.
    ///
    /// - Parameters:
    ///   - with: `TaxRepository`
    public init(with repository: TaxRepository) {
        self.repository = repository
    }
}

// NOTE: See the actual protocol in `KauppaTaxClient` for exact usage.
extension TaxService: TaxServiceCallable {
    public func getTaxRate(for address: Address) throws -> TaxRate {
        // FIXME: This could be done efficiently with the store?
        // Get the country first. This should match a valid country in the store.
        var taxRate: TaxRate? = nil
        do {
            let country = try repository.getCountry(name: address.country)
            taxRate = country.taxRate
        } catch ServiceError.noMatchingCountry {
            Loki.debug("Country \(address.country) doesn't exist. Responding with fallback tax rate.")
            return TaxConfiguration.fallbackTaxRate
        }

        // Try getting the province. If it matches, override the rates in country with
        // the values from province.
        do {
            let province = try repository.getRegion(name: address.province, for: address.country)
            taxRate!.applyOverrideFrom(province.taxRate)
        } catch ServiceError.noMatchingRegion {
            Loki.debug("Region \(address.province) doesn't exist. Falling through.")
        }

        do {
            let city = try repository.getRegion(name: address.city, for: address.country)
            taxRate!.applyOverrideFrom(city.taxRate)
        } catch ServiceError.noMatchingRegion {
            Loki.debug("City \(address.city) doesn't exist. Falling through.")
        }

        return taxRate!
    }

    public func createCountry(with data: CountryData) throws -> Country {
        let country = Country(name: data.name, taxRate: data.taxRate)
        try country.validate()
        try repository.createCountry(with: country)
        return country
    }

    public func updateCountry(for id: UUID, with data: CountryPatch) throws -> Country {
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

    public func deleteCountry(for id: UUID) throws -> () {
        try repository.deleteCountry(for: id)
    }

    public func addRegion(to id: UUID, using data: RegionData) throws -> Region {
        let _ = try repository.getCountry(id: id)
        let region = Region(name: data.name, taxRate: data.taxRate, kind: data.kind, country: id)
        try region.validate()
        try repository.createRegion(with: region)
        return region
    }

    public func updateRegion(for id: UUID, with data: RegionPatch) throws -> Region {
        var region = try repository.getRegion(for: id)

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

    public func deleteRegion(for id: UUID) throws -> () {
        return try repository.deleteRegion(for: id)
    }
}
