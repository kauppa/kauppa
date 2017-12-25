import Foundation
import XCTest

import KauppaCore
import KauppaAccountsModel
@testable import KauppaProductsModel
@testable import KauppaProductsRepository
@testable import KauppaProductsService

class TestProductAttributes: XCTestCase {
    var taxService = TestTaxService()

    static var allTests: [(String, (TestProductAttributes) -> () throws -> Void)] {
        return [
            ("Test attribute creation through products", testAttributeCreation),
            ("Test updating custom attribute values", testAttributeValueUpdates),
        ]
    }

    override func setUp() {
        taxService = TestTaxService()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Check that attributes can be created during product creation/update.
    func testAttributeCreation() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        var productData = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let baseProduct = try! service.createProduct(with: productData, from: Address())

        let validTests: [(String?, String?, String, String?)] = [
            ("surfaceArea", "area", "2", "sq. ft"),
            ("price", "currency", "3.75", "USD"),
            ("altitude", "length", "10", "km"),
            ("reducedWeight", "mass", "20", "kg"),
            ("someFount", "number", "127", nil),
            ("name", "string", "foobar", nil),
            ("fooExists", "boolean", "true", nil),
            ("boilingPoint", "temperature", "100", "C"),
            ("size", "volume", "2", "l")
        ]

        let invalidTests: [(String?, String?, String, String?)] = [
            (nil, "string", "booya", nil),
            ("", "area", "5", "sq. ft"),
            ("foo", "currency", "5", nil),
            ("boo", "length", "2", ""),
            ("something", "asdasdf", "20", nil)
        ]

        var tests = [(String?, String?, String, String?)]()
        tests.append(contentsOf: validTests)
        tests.append(contentsOf: invalidTests)

        for (i, (name, type, value, unit)) in tests.enumerated() {
            var attribute = CustomAttribute(with: value)
            attribute.name = name
            if let type = type {
                attribute.type = BaseType(rawValue: type)
            }

            attribute.unit = unit
            productData.custom = [attribute]

            let result1 = try? service.createProduct(with: productData, from: Address())

            var patch = ProductPatch()
            patch.custom = [attribute]
            let result2 = try? service.updateProduct(for: baseProduct.id, with: patch, from: Address())

            if i < validTests.count {
                XCTAssertNotNil(result1)
                XCTAssertNotNil(result2)
            } else {
                XCTAssertNil(result1)
                XCTAssertNil(result2)
            }
        }
    }
}
