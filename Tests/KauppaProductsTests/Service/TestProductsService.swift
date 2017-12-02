import Foundation
import XCTest

@testable import KauppaProductsModel
@testable import KauppaProductsRepository
@testable import KauppaProductsService

class TestProductsService: XCTestCase {

    static var allTests: [(String, (TestProductsService) -> () throws -> Void)] {
        return [
            ("Test product creation", testProductCreation),
            ("Test product with invalid variant", testProductWithInvalidVariant),
            ("Test product deletion", testProductDeletion),
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
        let creation = expectation(description: "Product created")
        let product = ProductData(title: "", subtitle: "", description: "")

        let data = service.createProduct(data: product)
        XCTAssertNotNil(data)
        creation.fulfill()

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    func testProductWithInvalidVariant() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        let rejection = expectation(description: "Variant rejected in product")
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.variantId = UUID()  // random UUID

        let product = service.createProduct(data: productData)!
        XCTAssertNil(product.data.variantId)
        rejection.fulfill()

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    func testProductDeletion() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        let deletion = expectation(description: "Product deleted")
        let product = ProductData(title: "", subtitle: "", description: "")

        let data = service.createProduct(data: product)!
        let isDeleted = service.deleteProduct(id: data.id)
        XCTAssertTrue(isDeleted)
        deletion.fulfill()

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }
}
