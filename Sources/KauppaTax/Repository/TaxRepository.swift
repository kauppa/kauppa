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
    ///
    /// - Parameters:
    ///   - with: Anything that implements `TaxStorable`
    public init(with store: TaxStorable) {
        self.store = store
    }

    /// Create a country with validated data from the service.
    ///
    /// - Parameters:
    ///   - with: The `Country` object.
    /// - Throws: `TaxError` on failure.
    public func createCountry(with data: Country) throws -> () {
        countries[data.id] = data
        countryNames[data.name] = data.id
        try store.createCountry(with: data)
    }

    /// Get the country for a given name (fetch it from store if it's not available)
    ///
    /// - Parameters:
    ///   - name: The name of the country.
    /// - Returns: `Country` (if it exists).
    /// - Throws: `TaxError` on failure.
    public func getCountry(name: String) throws -> Country {
        guard let id = countryNames[name] else {
            let data = try store.getCountry(name: name)
            countryNames[data.name] = data.id
            return data
        }

        return try getCountry(id: id)
    }

    /// Get the country for a given ID (fetch it from store if it's not available in repository)
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the country.
    /// - Returns: `Country` (if it exists).
    /// - Throws: `TaxError` on failure.
    public func getCountry(id: UUID) throws -> Country {
        guard let data = countries[id] else {
            let data = try store.getCountry(id: id)
            countries[id] = data
            return data
        }

        return data
    }

    /// Get the region matching a given name and belonging to a given country.
    ///
    /// - Parameters:
    ///   - name: The name of the region.
    ///   - for: The name of the country to which this region belongs to.
    /// - Returns: `Region` (if it exists).
    /// - Throws: `TaxError` on failure.
    public func getRegion(name: String, for countryName: String) throws -> Region {
        let country = try getCountry(name: countryName)
        var region: Region? = nil
        if let id = regionNames[name] {
            let r = try getRegion(for: id)
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
    ///
    /// - Parameters:
    ///   - with: Updated `Country` object from the service.
    /// - Returns: Updated `Country` (if it exists).
    /// - Throws: `TaxError` on failure.
    public func updateCountry(with data: Country) throws -> Country {
        var data = data
        data.updatedAt = Date()
        countries[data.id] = data
        try store.updateCountry(with: data)
        return data
    }

    /// Delete the country matching the given ID from cache and store.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the country.
    /// - Throws: `TaxError` on failure.
    public func deleteCountry(for id: UUID) throws -> () {
        let country = try getCountry(id: id)
        countries.removeValue(forKey: country.id)
        countryNames.removeValue(forKey: country.name)
        return try store.deleteCountry(for: id)
    }

    /// Get the region for a given ID (fetch it from store if it's not available in repository)
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the region.
    /// - Returns: `Region` object (if it exists).
    /// - Throws: `TaxError` on failure.
    public func getRegion(for id: UUID) throws -> Region {
        guard let data = regions[id] else {
            let data = try store.getRegion(id: id)
            regions[id] = data
            return data
        }

        return data
    }

    /// Create a region with the validated data from the service.
    ///
    /// - Parameters:
    ///   - with: The `Region` object from the service.
    /// - Throws: `TaxError` on failure.
    public func createRegion(with data: Region) throws -> () {
        regions[data.id] = data
        try store.createRegion(with: data)
    }

    /// Update the region data in repository and store.
    ///
    /// - Parameters:
    ///   - with: The updated `Region` object from the service.
    /// - Returns: Updated `Region` object (if it exists).
    /// - Throws: `TaxError` on failure.
    public func updateRegion(with data: Region) throws -> Region {
        var data = data
        data.updatedAt = Date()
        regions[data.id] = data
        try store.updateRegion(with: data)
        return data
    }

    /// Delete a region matching the given ID from cache and store.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the region.
    /// - Throws: `TaxError` on failure.
    public func deleteRegion(for id: UUID) throws -> () {
        regions.removeValue(forKey: id)
        try store.deleteRegion(for: id)
    }
}
