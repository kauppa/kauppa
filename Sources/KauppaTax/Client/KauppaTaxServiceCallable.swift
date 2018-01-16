import Foundation

import KauppaAccountsModel
import KauppaTaxModel

/// General API for the tax service to be implemented by both the service
/// and the client.
public protocol TaxServiceCallable {
    /// Create a country with the given data.
    ///
    /// - Parameters:
    ///   - with: The `CountryData` used for creation
    /// - Returns: `Country`
    /// - Throws: `TaxError` if there were errors (country not unique, invalid tax rate, etc.)
    func createCountry(with data: CountryData) throws -> Country

    /// Update a country with the given patch data.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the country to be updated.
    ///   - data: The `CountryPatch` data required for updating a country.
    /// - Returns: `Country`
    /// - Throws: `TaxError`
    func updateCountry(id: UUID, with data: CountryPatch) throws -> Country
}
