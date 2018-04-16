import Foundation

import KauppaCore
import KauppaTaxModel

/// Methods that mutate the underlying store with information.
public protocol TaxPersisting: Persisting {
    /// Create a country with data from the repository.
    ///
    /// - Parameters:
    ///   - with: `Country` object.
    /// - Throws: `TaxError` on failure.
    func createCountry(with data: Country) throws -> ()

    /// Update a country with data from repository.
    ///
    /// - Parameters:
    ///   - with: `Country` object.
    /// - Throws: `TaxError` on failure.
    func updateCountry(with data: Country) throws -> ()

    /// Delete a country corresponding to the given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the country.
    /// - Throws: `TaxError` on failure.
    func deleteCountry(for id: UUID) throws -> ()

    /// Create a region with data from the repository.
    ///
    /// - Parameters:
    ///   - with: `Region` object.
    /// - Throws: `TaxError` on failure.
    func createRegion(with data: Region) throws -> ()

    /// Update a region with data from repository.
    ///
    /// - Parameters:
    ///   - with: `Region` object.
    /// - Throws: `TaxError` on failure.
    func updateRegion(with data: Region) throws -> ()

    /// Delete a region corresponding to the given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the region.
    /// - Throws: `TaxError` on failure.
    func deleteRegion(for id: UUID) throws -> ()
}
