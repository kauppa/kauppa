import Foundation

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

    public func createCountry(with data: Country) throws -> () {
        createCountryCalled = true
        countries[data.id] = data
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
}
