import Foundation
import XCTest

import KauppaCore
@testable import KauppaProductsModel

class TestProductTypes: XCTestCase {
    static var allTests: [(String, (TestProductTypes) -> () throws -> Void)] {
        return [
            ("Test product data", testProductData),
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
}
