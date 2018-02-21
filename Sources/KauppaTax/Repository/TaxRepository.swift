import Foundation

import KauppaTaxModel
import KauppaTaxStore

/// Manages the retrieval and persistance of tax data from store.
public class TaxRepository {
    var countries = [UUID: Country]()
    var regions = [UUID: Region]()
    var countryNames = [String: UUID]()
    var regionNames = [String: UUID]()

    let store: TaxStorable

    /// Initialize this repository with the given store.
    public init(with store: TaxStorable) {
        self.store = store
    }

    /// Create a country with validated data from the service.
    public func createCountry(with data: Country) throws -> () {
        countries[data.id] = data
        countryNames[data.name] = data.id
        try store.createCountry(with: data)
    }

    /// Get the country for a given name (fetch it from store if it's not available)
    public func getCountry(name: String) throws -> Country {
        guard let id = countryNames[name] else {
            let data = try store.getCountry(name: name)
            countryNames[data.name] = data.id
            return data
        }

        return try getCountry(id: id)
    }

    /// Get the country for a given ID (fetch it from store if it's not available in repository)
    public func getCountry(id: UUID) throws -> Country {
        guard let data = countries[id] else {
            let data = try store.getCountry(id: id)
            countries[id] = data
            return data
        }

        return data
    }

    /// Get the region matching a given name and belonging to a given country.
    public func getRegion(name: String, for countryName: String) throws -> Region {
        let country = try getCountry(name: countryName)
        var region: Region? = nil
        if let id = regionNames[name] {
            let r = try getRegion(id: id)
            // Ensure that the region belongs to the given country.
            if r.countryId == country.id {
                region = r
            }
        }

        guard let regionData = region else {
            let region = try store.getRegion(name: name, for: countryName)
            regionNames[region.name] = region.id
            return region
        }

        return regionData
    }

    /// Update the country data in repository and store.
    public func updateCountry(with data: Country) throws -> Country {
        var data = data
        data.updatedAt = Date()
        countries[data.id] = data
        try store.updateCountry(with: data)
        return data
    }

    /// Delete the country matching the given ID from cache and store.
    public func deleteCountry(id: UUID) throws -> () {
        let country = try getCountry(id: id)
        countries.removeValue(forKey: country.id)
        countryNames.removeValue(forKey: country.name)
        return try store.deleteCountry(id: id)
    }

    /// Get the region for a given ID (fetch it from store if it's not available in repository)
    public func getRegion(id: UUID) throws -> Region {
        guard let data = regions[id] else {
            let data = try store.getRegion(id: id)
            regions[id] = data
            return data
        }

        return data
    }

    /// Create a region with the validated data from the service.
    public func createRegion(with data: Region) throws -> () {
        regions[data.id] = data
        try store.createRegion(with: data)
    }

    /// Update the region data in repository and store.
    public func updateRegion(with data: Region) throws -> Region {
        var data = data
        data.updatedAt = Date()
        regions[data.id] = data
        try store.updateRegion(with: data)
        return data
    }

    /// Delete a region matching the given ID from cache and store.
    public func deleteRegion(id: UUID) throws -> () {
        regions.removeValue(forKey: id)
        try store.deleteRegion(id: id)
    }
}
