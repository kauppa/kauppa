import Foundation

import KauppaCore
import KauppaTaxModel

/// Methods that mutate the underlying store with information.
public protocol TaxPersisting: Persisting {
    /// Create a country with data from the repository.
    func createCountry(with data: Country) throws -> ()

    /// Update a country with data from repository.
    func updateCountry(with data: Country) throws -> ()

    /// Delete a country corresponding to the given ID.
    func deleteCountry(id: UUID) throws -> ()

    /// Create a region with data from the repository.
    func createRegion(with data: Region) throws -> ()
}
