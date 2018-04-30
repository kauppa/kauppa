import Foundation

import KauppaAccountsModel
import KauppaTaxModel

/// General API for the tax service to be implemented by both the service
/// and the client.
public protocol TaxServiceCallable {
    /// Get the tax rate for a given address.
    ///
    /// - Parameters:
    ///   - for: The `Address` for which the rate should be calculated.
    /// - Returns: `TaxRate` for the matching area.
    /// - Throws: `ServiceError` if the tax rate could not be obtained.
    func getTaxRate(for address: Address) throws -> TaxRate
    /// Create a country with the given data.
    ///
    /// - Parameters:
    ///   - with: The `CountryData` used for creation
    /// - Returns: `Country`
    /// - Throws: `ServiceError` if there were errors (country not unique, invalid tax rate, etc.)
    func createCountry(with data: CountryData) throws -> Country

    /// Update a country with the given patch data.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the country to be updated.
    ///   - with: The `CountryPatch` data required for updating the country.
    /// - Returns: `Country`
    /// - Throws: `ServiceError` on failure.
    func updateCountry(for id: UUID, with data: CountryPatch) throws -> Country

    /// Delete a country corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the country to be deleted.
    /// - Throws: `ServiceError` if the country doesn't exist.
    func deleteCountry(for id: UUID) throws -> ()

    /// Create a new region for a country.
    ///
    /// - Parameters:
    ///   - to: The `UUID` of the country to which the region is to be added.
    ///   - using: `RegionData` input for creating a region.
    /// - Returns: `Region`
    /// - Throws: `ServiceError` on failure.
    func addRegion(to id: UUID, using data: RegionData) throws -> Region

    /// Update a region with the given patch data.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the region to be updated.
    ///   - with: The `RegionPatch` data required for updating the region.
    /// Returns: `Region`
    /// Throws: `ServiceError` on failure.
    func updateRegion(for id: UUID, with data: RegionPatch) throws -> Region

    /// Delete a region corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the region to be deleted.
    /// - Throws: `ServiceError` if the region doesn't exist.
    func deleteRegion(for id: UUID) throws -> ()
}
