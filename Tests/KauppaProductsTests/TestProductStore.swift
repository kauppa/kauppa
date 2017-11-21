import Foundation
import XCTest

@testable import KauppaCore

class TestProductsService: XCTestCase {
    var store = MemoryStore()

    static var allTests: [(String, (TestProductsService) -> () throws -> Void)] {
        return [
            ("ProductCreation", testProductCreation),
        ]
    }

    override func setUp() {
        store = MemoryStore()

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func createProductData() -> ProductData {
        let string = """
            {
                "title": "Foo",
                "subtitle": "Bar",
                "description": "foo bar",
                "size": {
                    "length": { "value": 5.0, "unit": "cm" },
                    "width": { "value": 4.0, "unit": "cm" },
                    "height": { "value": 50.0, "unit": "cm" }
                },
                "color": "black",
                "weight": {
                    "value": 100.0,
                    "unit": "g"
                },
                "images": []
            }
        """

        let jsonData = string.data(using: .utf8)!
        let data = try! JSONDecoder().decode(ProductData.self, from: jsonData)
        return data
    }

    func testProductCreation() {
        let creation = expectation(description: "Product created")
        let product = self.createProductData()

        store.createProduct(data: product, callback: { data in
            creation.fulfill()
        })

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
}
