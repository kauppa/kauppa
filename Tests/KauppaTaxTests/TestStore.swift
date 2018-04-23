import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaTaxModel
import KauppaTaxStore

public class TestStore: TaxStorable {
    var countries = [UUID: Country]()
    var regions = [UUID: Region]()

    // Variables to indicate the function calls
    var createCountryCalled = false
    var getCountryCalled = false
    var updateCountryCalled = false
    var deleteCountryCalled = false
    var createRegionCalled = false
    var getRegionCalled = false
    var updateRegionCalled = false
    var deleteRegionCalled = false

    public func createCountry(with data: Country) throws -> () {
        createCountryCalled = true
        countries[data.id] = data
    }

    public func getCountry(name: String) throws -> Country {
        getCountryCalled = true
        for (_, country) in countries {
            if country.name == name {
                return country
            }
        }

        throw ServiceError.noMatchingCountry
    }

    public func getCountry(id: UUID) throws -> Country {
        getCountryCalled = true
        guard let data = countries[id] else {
            throw ServiceError.invalidCountryId
        }

        return data
    }

    public func updateCountry(with data: Country) throws -> () {
        updateCountryCalled = true
        countries[data.id] = data
    }

    public func deleteCountry(for id: UUID) throws -> () {
        deleteCountryCalled = true
        countries.removeValue(forKey: id)
    }

    public func createRegion(with data: Region) throws -> () {
        createRegionCalled = true
        regions[data.id] = data
    }

    public func getRegion(id: UUID) throws -> Region {
        getRegionCalled = true
        guard let data = regions[id] else {
            throw ServiceError.invalidRegionId
        }

        return data
    }

    public func getRegion(name: String, for countryName: String) throws -> Region {
        getRegionCalled = true
        let country = try getCountry(name: countryName)
        for (_, region) in regions {
            if region.name == name && region.countryId == country.id {
                return region
            }
        }

        throw ServiceError.noMatchingRegion
    }

    public func updateRegion(with data: Region) throws -> () {
        updateRegionCalled = true
        regions[data.id] = data
    }

    public func deleteRegion(for id: UUID) throws -> () {
        deleteRegionCalled = true
        regions.removeValue(forKey: id)
    }
}
