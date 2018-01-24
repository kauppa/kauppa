import Foundation
import XCTest

import KauppaAccountsModel
import KauppaTaxClient
import KauppaTaxModel

typealias TaxCallback = (Address) -> Void

class TestTaxService: TaxServiceCallable {
    var callback: TaxCallback? = nil
    var rate: TaxRate? = nil

    public func getTaxRate(forAddress address: Address) throws -> TaxRate {
        if let callback = callback {
            callback(address)
        }

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
    public func addRegion(toCountry id: UUID, data: RegionData) throws -> Region {
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
