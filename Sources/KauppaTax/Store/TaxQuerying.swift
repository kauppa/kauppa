import Foundation

import KauppaCore
import KauppaTaxModel

/// Methods that fetch data from the underlying store.
public protocol TaxQuerying: Querying {
    /// Get the country corresponding to the given ID from the store for the repository.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the country.
    /// - Returns: `Country` object (if it exists).
    /// - Throws: `TaxError` on failure.
    func getCountry(id: UUID) throws -> Country

    /// Get the region corresponding to the given ID from store for the repository.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the region.
    /// - Returns: `Country` object (if it exists).
    /// - Throws: `TaxError` on failure.
    func getRegion(id: UUID) throws -> Region

    /// Get country matching the given name.
    ///
    /// - Parameters:
    ///   - name: The name of the country.
    /// - Returns: `Country` object (if it exists).
    /// - Throws: `TaxError` on failure.
    func getCountry(name: String) throws -> Country

    /// Get the region matching a given name and belonging to a given country.
    ///
    /// - Parameters:
    ///   - name: The name of the region.
    ///   - for: The name of the country to which this region belongs to.
    /// - Returns: `Region` object (if it exists).
    /// - Throws: `TaxError` on failure.
    func getRegion(name: String, for countryName: String) throws -> Region
}
