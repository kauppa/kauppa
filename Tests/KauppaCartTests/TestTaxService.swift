import Foundation
import XCTest

import KauppaAccountsModel
import KauppaTaxClient
import KauppaTaxModel

class TestTaxService: TaxServiceCallable {
    var rate: TaxRate? = nil

    public func getTaxRate(for address: Address) throws -> TaxRate {
        return rate ?? TaxRate()
    }

    // NOTE: Not meant to be called by cart
    public func createCountry(with data: CountryData) throws -> Country {
        throw TaxError.invalidCountryId
    }

    // NOTE: Not meant to be called by cart
    public func updateCountry(id: UUID, with data: CountryPatch) throws -> Country {
        throw TaxError.invalidCountryId
    }

    // NOTE: Not meant to be called by cart
    public func deleteCountry(id: UUID) throws -> () {
        throw TaxError.invalidCountryId
    }

    // NOTE: Not meant to be called by cart
    public func addRegion(to id: UUID, data: RegionData) throws -> Region {
        throw TaxError.invalidRegionId
    }

    // NOTE: Not meant to be called by cart
    public func updateRegion(id: UUID, with data: RegionPatch) throws -> Region {
        throw TaxError.invalidRegionId
    }

    // NOTE: Not meant to be called by cart
    public func deleteRegion(id: UUID) throws -> () {
        throw TaxError.invalidRegionId
    }
}
