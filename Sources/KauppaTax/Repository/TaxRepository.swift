import Foundation

import KauppaTaxModel
import KauppaTaxStore

/// Manages the retrieval and persistance of tax data from store.
public class TaxRepository {
    var countries = [UUID: Country]()

    let store: TaxStorable

    /// Initialize this repository with the given store.
    public init(withStore store: TaxStorable) {
        self.store = store
    }

    /// Create a country with validated data from the service.
    public func createCountry(with data: Country) throws -> () {
        countries[data.id] = data
        try store.createCountry(with: data)
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

    /// Update the country data in repository and store.
    public func updateCountry(with data: Country) throws -> Country {
        var data = data
        data.updatedAt = Date()
        countries[data.id] = data
        try store.updateCountry(with: data)
        return data
    }
}
