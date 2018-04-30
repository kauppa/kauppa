import XCTest

import KauppaCore
@testable import KauppaTaxModel

class TestTaxTypes: XCTestCase {
    static var allTests: [(String, (TestTaxTypes) -> () throws -> Void)] {
        return [
            ("Test country validation", testCountry),
            ("Test region validation", testRegion),
        ]
    }

    func testCountry() {
        var cases = [(Country, ServiceError)]()
        var rate = TaxRate()
        cases.append((Country(name: "", taxRate: rate), .invalidCountryName))
        rate.general = -0.1
        cases.append((Country(name: "foo", taxRate: rate), .invalidTaxRate))
        rate.general = 1000.1
        cases.append((Country(name: "foo", taxRate: rate), .invalidTaxRate))
        rate.general = 5.0
        rate.categories["food"] = -0.1
        cases.append((Country(name: "foo", taxRate: rate), .invalidCategoryTaxRate))
        rate.categories["food"] = 1000.1
        cases.append((Country(name: "foo", taxRate: rate), .invalidCategoryTaxRate))

        for (testCase, error) in cases {
            do {
                let _ = try testCase.validate()
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }

    func testRegion() {
        var cases = [(Region, ServiceError)]()
        var rate = TaxRate()
        cases.append((Region(name: "", taxRate: rate, kind: .province, country: UUID()),
                      .invalidRegionName))
        rate.general = -0.1
        cases.append((Region(name: "foo", taxRate: rate, kind: .district, country: UUID()),
                      .invalidTaxRate))
        rate.general = 1000.1
        cases.append((Region(name: "foo", taxRate: rate, kind: .city, country: UUID()),
                      .invalidTaxRate))
        rate.general = 5.0
        rate.categories["food"] = -0.1
        cases.append((Region(name: "foo", taxRate: rate, kind: .city, country: UUID()),
                      .invalidCategoryTaxRate))
        rate.categories["food"] = 1000.1
        cases.append((Region(name: "foo", taxRate: rate, kind: .city, country: UUID()),
                      .invalidCategoryTaxRate))

        for (testCase, error) in cases {
            do {
                let _ = try testCase.validate()
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }
}
