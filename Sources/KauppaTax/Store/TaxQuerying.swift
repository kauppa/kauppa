import Foundation

import KauppaCore
import KauppaTaxModel

/// Methods that fetch data from the underlying store.
public protocol TaxQuerying: Querying {
    /// Get the country corresponding to the given ID from the store for the repository.
    func getCountry(id: UUID) throws -> Country

    /// Get the region corresponding to the given ID from store for the repository.
    func getRegion(id: UUID) throws -> Region

    /// Get country matching the given name.
    func getCountry(name: String) throws -> Country
}
