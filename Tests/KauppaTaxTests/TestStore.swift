import Foundation

import KauppaTaxModel
import KauppaTaxStore

public class TestStore: TaxStorable {
    // Variables to indicate the function calls
    var createCalled = true

    public func createCountry(with data: Country) throws -> () {
        createCalled = true
    }
}
