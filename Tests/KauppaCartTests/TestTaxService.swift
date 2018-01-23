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

        return rate!
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
}
