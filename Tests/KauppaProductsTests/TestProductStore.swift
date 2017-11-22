import Foundation
import XCTest

@testable import KauppaCore

class TestProductsService: XCTestCase {
    var store = MemoryStore()

    static var allTests: [(String, (TestProductsService) -> () throws -> Void)] {
        return [
            ("ProductCreation", testProductCreation),
            ("ProductDeletion", testProductDeletion),
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
                "inventory": 5,
                "images": [],
                "price": 15.0
            }
        """

        let jsonData = string.data(using: .utf8)!
        let data = try! JSONDecoder().decode(ProductData.self, from: jsonData)
        return data
    }

    func testProductCreation() {
        let creation = expectation(description: "Product created")
        let product = self.createProductData()

        let data = store.createProduct(data: product)!
        let id = Array(self.store.products.keys)[0]
        XCTAssertEqual(id, data.id)
        creation.fulfill()

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }

    func testProductDeletion() {
        let deletion = expectation(description: "Product deleted")
        let product = self.createProductData()

        let data = store.createProduct(data: product)
        XCTAssertNotNil(data)
        let id = Array(self.store.products.keys)[0]
        let productData = self.store.deleteProduct(id: id)
        XCTAssertNotNil(productData)
        deletion.fulfill()

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
}
