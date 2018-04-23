import Foundation
import XCTest

import KauppaCore
import KauppaAccountsModel
import KauppaTaxClient
@testable import KauppaTaxModel

class TestTaxService: TaxServiceCallable {
    var rate: TaxRate? = nil

    public func getTaxRate(for address: Address) throws -> TaxRate {
        return rate ?? TaxRate()
    }

    // NOTE: Not meant to be called by orders
    public func createCountry(with data: CountryData) throws -> Country {
        throw ServiceError.invalidCountryId
    }

    // NOTE: Not meant to be called by orders
    public func updateCountry(for id: UUID, with data: CountryPatch) throws -> Country {
        throw ServiceError.invalidCountryId
    }

    // NOTE: Not meant to be called by orders
    public func deleteCountry(for id: UUID) throws -> () {
        throw ServiceError.invalidCountryId
    }

    // NOTE: Not meant to be called by orders
    public func addRegion(to id: UUID, using data: RegionData) throws -> Region {
        throw ServiceError.invalidRegionId
    }

    // NOTE: Not meant to be called by orders
    public func updateRegion(for id: UUID, with data: RegionPatch) throws -> Region {
        throw ServiceError.invalidRegionId
    }

    // NOTE: Not meant to be called by orders
    public func deleteRegion(for id: UUID) throws -> () {
        throw ServiceError.invalidRegionId
    }
}
