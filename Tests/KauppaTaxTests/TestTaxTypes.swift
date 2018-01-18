import XCTest

import KauppaTaxModel

class TestTaxTypes: XCTestCase {
    static var allTests: [(String, (TestTaxTypes) -> () throws -> Void)] {
        return [
            ("Test country validation", testCountry),
        ]
    }

    func testCountry() {
        var cases = [(Country, TaxError)]()
        var rate = TaxRate()
        cases.append((Country(name: "", taxRate: rate), .invalidCountryName))
        rate.general = -0.1
        cases.append((Country(name: "foo", taxRate: rate), .invalidTaxRate))
        rate.general = 1000.1
        cases.append((Country(name: "foo", taxRate: rate), .invalidTaxRate))
        rate.general = 5.0
        rate.categories["food"] = -0.1
        cases.append((Country(name: "foo", taxRate: rate), .invalidCategoryTaxRate("food")))
        rate.categories["food"] = 1000.1
        cases.append((Country(name: "foo", taxRate: rate), .invalidCategoryTaxRate("food")))

        for (testCase, error) in cases {
            do {
                let _ = try testCase.validate()
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! TaxError, error)
            }
        }
    }
}
