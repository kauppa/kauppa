import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaProductsModel
@testable import KauppaProductsRepository
@testable import KauppaProductsService

class TestProductsService: XCTestCase {

    static var allTests: [(String, (TestProductsService) -> () throws -> Void)] {
        return [
            ("Test product creation", testProductCreation),
            ("Test product deletion", testProductDeletion),
            ("Test update of product", testProductUpdate),
            ("Test individual property deletion", testPropertyDeletion),
            ("Test individual property addition", testPropertyAddition),
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
            ("images", ["data:image/gif;base64,foobar", "data:image/gif;base64,foo"]),
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
        XCTAssertEqual(updatedProduct.data.images.inner,
                       ["data:image/gif;base64,foobar", "data:image/gif;base64,foo"])
        XCTAssertEqual(updatedProduct.data.price, 30.0)
        XCTAssertEqual(updatedProduct.data.category, .electronics)
        XCTAssert(updatedProduct.createdOn < updatedProduct.updatedAt)
        XCTAssertEqual(updatedProduct.data.variantId, anotherId)

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }

    func testPropertyAddition() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        let product = ProductData(title: "", subtitle: "", description: "")
        let data = try! service.createProduct(data: product)
        XCTAssertEqual(data.data.images.inner, [])      // no images

        var patch = ProductPropertyAdditionPatch()
        patch.image = "data:image/png;base64,foobar"
        let updatedProduct = try! service.addProductProperty(id: data.id, data: patch)
        // image should've been added
        XCTAssertEqual(updatedProduct.data.images.inner, ["data:image/png;base64,foobar"])
    }

    func testPropertyDeletion() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        var product = ProductData(title: "", subtitle: "", description: "")
        // set all additional attributes required for testing
        product.images.inner = ["data:image/png;base64,bar", "data:image/png;base64,baz"]
        product.color = "blue"
        product.weight = UnitMeasurement(value: 50.0, unit: .gram)
        var size = Size()
        size.length = UnitMeasurement(value: 10.0, unit: .centimeter)
        product.size = size
        product.category = .food
        // variant is checked in `TestProductVariants`
        let data = try! service.createProduct(data: product)

        var patch = ProductPropertyDeletionPatch()
        patch.removeCategory = true
        patch.removeColor = true
        patch.removeSize = true
        patch.removeWeight = true
        patch.removeImageAt = 0     // remove image at zero'th index
        let updatedProduct = try! service.deleteProductProperty(id: data.id, data: patch)
        XCTAssertEqual(updatedProduct.data.images.inner, ["data:image/png;base64,baz"])
        XCTAssertNil(updatedProduct.data.size)
        XCTAssertNil(updatedProduct.data.category)
        XCTAssertNil(updatedProduct.data.color)
        XCTAssertNil(updatedProduct.data.weight)
    }
}
