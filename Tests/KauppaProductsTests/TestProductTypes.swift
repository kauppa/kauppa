import Foundation
import XCTest

import KauppaCore
@testable import KauppaProductsModel

class TestProductTypes: XCTestCase {
    static var allTests: [(String, (TestProductTypes) -> () throws -> Void)] {
        return [
            ("Test product data", testProductData),
            ("Test collection data", testCollectionData),
        ]
    }

    func testProductData() {
        var data = ProductData(title: "", subtitle: "", description: "")
        var tests = [(ProductData, ProductsError)]()
        tests.append((data, ProductsError.invalidTitle))
        data.title = "foo"
        tests.append((data, ProductsError.invalidSubtitle))
        data.subtitle = "bar"
        tests.append((data, ProductsError.invalidDescription))
        data.description = "foobar"
        data.color = "#sadaddad"
        tests.append((data, ProductsError.invalidColor))
        data.color = "#"
        tests.append((data, ProductsError.invalidColor))

        for (testCase, error) in tests {
            do {
                try testCase.validate()
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ProductsError, error)
            }
        }
    }

    func testCollectionData() {
        var data = ProductCollectionData(name: "", description: "", products: [])
        var tests = [(ProductCollectionData, ProductsError)]()
        tests.append((data, ProductsError.invalidCollectionName))
        data.name = "foo"
        tests.append((data, ProductsError.invalidCollectionDescription))

        for (testCase, error) in tests {
            do {
                try testCase.validate()
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ProductsError, error)
            }
        }
    }
}
