import Foundation
import XCTest

@testable import KauppaProductsModel
@testable import KauppaProductsRepository
@testable import KauppaProductsService

class TestProductsService: XCTestCase {

    static var allTests: [(String, (TestProductsService) -> () throws -> Void)] {
        return [
            ("Test product creation", testProductCreation),
            ("Test product deletion", testProductDeletion),
            ("Test update of product", testProductUpdate),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testProductCreation() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        let product = ProductData(title: "", subtitle: "", description: "")
        let data = try? service.createProduct(data: product)
        XCTAssertNotNil(data)       // product data should exist
    }

    func testProductDeletion() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        let product = ProductData(title: "", subtitle: "", description: "")
        let data = try! service.createProduct(data: product)
        let result: ()? = try? service.deleteProduct(id: data.id)
        XCTAssertNotNil(result)     // deletion succeeded
    }

    func testProductUpdate() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        let product = ProductData(title: "Foo",
                                  subtitle: "Bar",
                                  description: "Foobar")
        let data = try! service.createProduct(data: product)
        let productId = data.id

        let anotherProduct = ProductData(title: "", subtitle: "", description: "")
        let anotherData = try! service.createProduct(data: anotherProduct)
        let anotherId = anotherData.id
        let randomId = UUID()

        // Prefering JSON data over manually writing all the test cases
        let validTests: [(String, Any)] = [
            ("title", "\"Foobar\""),
            ("subtitle", "\"Baz\""),
            ("description", "\"Foo Bar Baz\""),
            ("size", "{\"length\": {\"value\": 10.0, \"unit\": \"cm\"}}"),
            ("size", "{\"height\": {\"value\": 1.0, \"unit\": \"m\"}}"),
            ("size", "{\"width\": {\"value\": 0.5, \"unit\": \"mm\"}}"),
            ("weight", "{\"value\": 500.0, \"unit\": \"g\"}"),
            ("color", "\"blue\""),
            ("inventory", 20),
            ("category", "\"electronics\""),
            ("images", ["data:image/gif;base64,foobar"]),
            ("price", 30.0),
            ("variantId", "\"\(anotherId)\""),
            ("variantId", "\"\(productId)\""),      // Self ID (shouldn't update)
        ]

        let invalidTests: [(String, Any)] = [
            ("variantId", "\"\(randomId)\""),       // non-existent ID (shouldn't update)
        ]

        var tests = [(String, Any)]()
        tests.append(contentsOf: validTests)
        tests.append(contentsOf: invalidTests)
        var i = 0

        for (attribute, value) in tests {
            let expectation_ = expectation(description: "Updated \(attribute)")
            let jsonStr = "{\"\(attribute)\": \(value)}"
            let jsonData = jsonStr.data(using: .utf8)!
            let data = try! JSONDecoder().decode(ProductPatch.self, from: jsonData)
            let result = try? service.updateProduct(id: productId, data: data)
            if i < validTests.count {
                XCTAssertNotNil(result)
            } else {
                XCTAssertNil(result)
            }

            expectation_.fulfill()
            i += 1
        }

        // All successful updates
        let updatedProduct = try! service.getProduct(id: productId)
        XCTAssertEqual(updatedProduct.data.title, "Foobar")
        XCTAssertEqual(updatedProduct.data.subtitle, "Baz")
        XCTAssertEqual(updatedProduct.data.description, "Foo Bar Baz")
        XCTAssert(updatedProduct.data.size!.length!.value == 10.0)
        XCTAssert(updatedProduct.data.size!.length!.unit == .centimeter)
        XCTAssert(updatedProduct.data.size!.width!.value == 0.5)
        XCTAssert(updatedProduct.data.size!.width!.unit == .millimeter)
        XCTAssert(updatedProduct.data.size!.height!.value == 1.0)
        XCTAssert(updatedProduct.data.size!.height!.unit == .meter)
        XCTAssert(updatedProduct.data.weight!.value == 500.0)
        XCTAssert(updatedProduct.data.weight!.unit == .gram)
        XCTAssertEqual(updatedProduct.data.color, "blue")
        XCTAssertEqual(updatedProduct.data.inventory, 20)
        XCTAssertEqual(updatedProduct.data.images, ["data:image/gif;base64,foobar"])
        XCTAssertEqual(updatedProduct.data.price, 30.0)
        XCTAssertEqual(updatedProduct.data.category, .electronics)
        XCTAssert(updatedProduct.createdOn < updatedProduct.updatedAt)
        XCTAssertEqual(updatedProduct.data.variantId, anotherId)

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
}
