import Foundation

import KauppaTaxModel
import KauppaTaxStore

public class TestStore: TaxStorable {
    var countries = [UUID: Country]()

    // Variables to indicate the function calls
    var createCalled = false
    var getCalled = false
    var updateCalled = false

    public func createCountry(with data: Country) throws -> () {
        createCalled = true
        countries[data.id] = data
    }

    public func getCountry(id: UUID) throws -> Country {
        getCalled = true
        guard let data = countries[id] else {
            throw TaxError.invalidCountryId
        }

        return data
    }

    public func updateCountry(with data: Country) throws -> () {
        updateCalled = true
        countries[data.id] = data
    }
}
