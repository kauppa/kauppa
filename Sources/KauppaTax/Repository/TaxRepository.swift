import Foundation
import KauppaTaxModel
import KauppaTaxStore

/// Manages the retrieval and persistance of tax data from store.
public class TaxRepository {
    var countries = [UUID: Country]()
    var countryNames = [String: UUID]()

    let store: TaxStorable

    /// Initialize this repository with the given store.
    public init(withStore store: TaxStorable) {
        self.store = store
    }

    /// Create a country with validated data from the service.
    public func createCountry(with data: Country) throws -> () {
        countries[data.id] = data
        countryNames[data.name] = data.id
        try store.createCountry(with: data)
    }
}
