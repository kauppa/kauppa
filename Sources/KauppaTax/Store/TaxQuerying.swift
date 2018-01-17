import Foundation

import KauppaCore
import KauppaTaxModel

/// Methods that fetch data from the underlying store.
public protocol TaxQuerying: Querying {
    /// Get country corresponding to the given ID from the store for the repository.
    func getCountry(id: UUID) throws -> Country
}
