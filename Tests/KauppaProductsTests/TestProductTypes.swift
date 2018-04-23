import Foundation
import XCTest

import KauppaCore
@testable import KauppaTaxModel
@testable import KauppaProductsModel

class TestProductTypes: XCTestCase {
    static var allTests: [(String, (TestProductTypes) -> () throws -> Void)] {
        return [
            ("Test product data", testProductData),
            ("Test collection data", testCollectionData),
            ("Test product tax stripping", testProductTaxStrip),
            ("Test product tax apply", testProductTaxApply),
        ]
    }

    func testProductData() {
        var data = Product(title: "", subtitle: "", description: "")
        var tests = [(Product, ServiceError)]()
        tests.append((data, ServiceError.invalidProductTitle))
        data.title = "foo"
        tests.append((data, ServiceError.invalidProductSubtitle))
        data.subtitle = "bar"
        tests.append((data, ServiceError.invalidProductDescription))
        data.description = "foobar"
        data.color = "#sadaddad"
        tests.append((data, ServiceError.invalidProductColor))
        data.color = "#"
        tests.append((data, ServiceError.invalidProductColor))

        for (testCase, error) in tests {
            do {
                try testCase.validate()
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }

    /// Test that tax is properly stripped when tax is included along with price.
    func testProductTaxStrip() {
        var data = Product(title: "", subtitle: "", description: "")
        data.tax = UnitTax()
        data.taxCategory = "food"
        var rate = TaxRate()
        rate.general = 10.0
        data.price.value = 10.0
        data.taxInclusive = true
        data.stripTax(using: rate)
        XCTAssertFalse(data.taxInclusive!)  // flag has been reverted
        XCTAssertNil(data.tax)      // Tax data is reset
        XCTAssertTrue(data.price.value > 9.090909 && data.price.value < 9.09091)

        // tax category matches with product tax category, hence this should be chosen
        rate.categories["food"] = 12.0
        data.price.value = 5.0
        data.taxInclusive = true
        data.stripTax(using: rate)
        XCTAssertTrue(data.price.value > 4.46428571 && data.price.value < 4.46428572)

        data.taxInclusive = false
        data.price.value = 10.0
        data.stripTax(using: rate)
        XCTAssertEqual(data.price.value, 10.0)
    }

    /// Test applying tax data to the product with a given rate.
    func testProductTaxApply() {
        var data = Product(title: "", subtitle: "", description: "")
        XCTAssertNil(data.tax)
        var rate = TaxRate()
        rate.general = 10.0
        data.price.value = 10.0
        data.taxCategory = "some unknown category"
        data.setTax(using: rate)
        XCTAssertEqual(data.tax!.rate, 10.0)
        XCTAssertNil(data.tax!.category)        // unknown category is ignored
        XCTAssertEqual(data.tax!.total.value, 1.0)

        data.taxCategory = "drink"
        rate.categories["drink"] = 8.0
        data.setTax(using: rate)
        XCTAssertEqual(data.tax!.rate, 8.0)
        XCTAssertEqual(data.tax!.category, "drink")     // matching category is applied
        XCTAssertEqual(data.tax!.total.value, 0.8)
    }

    func testCollectionData() {
        var data = ProductCollectionData(name: "", description: "", products: [])
        var tests = [(ProductCollectionData, ServiceError)]()
        tests.append((data, ServiceError.invalidCollectionName))
        data.name = "foo"
        tests.append((data, ServiceError.invalidCollectionDescription))

        for (testCase, error) in tests {
            do {
                try testCase.validate()
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }
}
