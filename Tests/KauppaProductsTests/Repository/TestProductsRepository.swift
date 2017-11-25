import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaProductsModel
@testable import KauppaProducts

class TestProductsRepository: XCTestCase {

    static var allTests: [(String, (TestProductsRepository) -> () throws -> Void)] {
        return [
            //("Test product creation", testProductCreation),
            //("Test product deletion", testProductDeletion),
            //("Test update of product", testProductUpdate),
        ]
    }

    override func setUp() {

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    /*func testProductCreation() {
        let creation = expectation(description: "Product created")
        let product = ProductData(title: "", subtitle: "", description: "")

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
        let product = ProductData(title: "", subtitle: "", description: "")

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

    func testProductUpdate() {
        let product = ProductData(title: "", subtitle: "", description: "")
        let data = store.createProduct(data: product)!
        let productId = data.id
        XCTAssertEqual(data.createdOn, data.updatedAt)

        let anotherProduct = ProductData(title: "", subtitle: "", description: "")
        let anotherData = store.createProduct(data: anotherProduct)!
        let anotherId = anotherData.id
        let randomId = UUID()

        let tests: [(String, Any)] = [
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
            ("variantId", "\"\(randomId)\""),       // non-existent ID (shouldn't update)
        ]

        for (attribute, value) in tests {
            let expectation_ = expectation(description: "Updated \(attribute)")
            let jsonStr = "{\"\(attribute)\": \(value)}"
            let data: ProductPatch = ProductPatch(
                title: "",
                subtitle: "",
                description: "",
                category: nil,
                size: nil,
                color: "",
                weight: nil,
                inventory: 0,
                images: nil,
                price: 0.0,
                variantId: nil
            )
            let result = store.updateProduct(id: productId, data: data)
            XCTAssertNotNil(result)
            expectation_.fulfill()
        }

        // All successful updates
        let updatedProduct = store.getProduct(id: productId)!
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
        XCTAssertEqual(updatedProduct.data.images, tests[10].1 as! [String])
        XCTAssertEqual(updatedProduct.data.price, 30.0)
        XCTAssertEqual(updatedProduct.data.category, .electronics)
        XCTAssert(updatedProduct.createdOn < updatedProduct.updatedAt)
        XCTAssertEqual(updatedProduct.data.variantId, anotherId)

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }*/
}
