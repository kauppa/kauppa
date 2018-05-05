import Foundation
import XCTest

import KauppaCore
@testable import KauppaTaxModel
@testable import KauppaProductsModel
@testable import TestTypes

class TestProductTypes: XCTestCase {
    static var allTests: [(String, (TestProductTypes) -> () throws -> Void)] {
        return [
            ("Test product data", testProductData),
            ("Test collection data", testCollectionData),
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

    /// Test applying tax data to the product with a given rate.
    func testProductTaxApply() {
        var data = Product(title: "", subtitle: "", description: "")
        XCTAssertNil(data.tax)
        var rate = TaxRate()
        rate.general = 10.0
        data.price = Price(10)
        data.taxCategory = "some unknown category"
        data.setTax(using: rate)
        XCTAssertEqual(data.tax!.rate, 10.0)
        XCTAssertNil(data.tax!.category)        // unknown category is ignored
        TestApproxEqual(data.tax!.total.value, 1.0)

        data.taxCategory = "drink"
        rate.categories["drink"] = 8.0
        data.setTax(using: rate)
        XCTAssertEqual(data.tax!.rate, 8.0)
        XCTAssertEqual(data.tax!.category, "drink")     // matching category is applied
        TestApproxEqual(data.tax!.total.value, 0.8)
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
