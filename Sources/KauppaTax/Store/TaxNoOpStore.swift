import Foundation

import KauppaCore
import KauppaTaxModel

/// A no-op store for tax data which doesn't support data persistence/querying.
/// This way, the repository takes care of all service requests by providing
/// in-memory data.
public class TaxNoOpStore: TaxStorable {
    public init() {}

    public func createCountry(with data: Country) throws -> () {}

    public func getCountry(name: String) throws -> Country {
        throw ServiceError.noMatchingCountry
    }

    public func getCountry(id: UUID) throws -> Country {
        throw ServiceError.invalidCountryId
    }

    public func updateCountry(with data: Country) throws -> () {}

    public func deleteCountry(for id: UUID) throws -> () {}

    public func createRegion(with data: Region) throws -> () {}

    public func getRegion(id: UUID) throws -> Region {
        throw ServiceError.invalidRegionId
    }

    public func getRegion(name: String, for countryName: String) throws -> Region {
        throw ServiceError.noMatchingRegion
    }

    public func updateRegion(with data: Region) throws -> () {}

    public func deleteRegion(for id: UUID) throws -> () {}
}
