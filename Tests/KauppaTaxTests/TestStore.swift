import Foundation

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
        for (_, country) in countries {
            if country.name == name {
                return country
            }
        }

        throw TaxError.noMatchingTaxRate
    }

    public func getCountry(id: UUID) throws -> Country {
        getCountryCalled = true
        guard let data = countries[id] else {
            throw TaxError.invalidCountryId
        }

        return data
    }

    public func updateCountry(with data: Country) throws -> () {
        updateCountryCalled = true
        countries[data.id] = data
    }

    public func deleteCountry(id: UUID) throws -> () {
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
            throw TaxError.invalidRegionId
        }

        return data
    }

    public func updateRegion(with data: Region) throws -> () {
        updateRegionCalled = true
        regions[data.id] = data
    }

    public func deleteRegion(id: UUID) throws -> () {
        deleteRegionCalled = true
        regions.removeValue(forKey: id)
    }
}
