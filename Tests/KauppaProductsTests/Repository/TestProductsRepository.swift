import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaProductsModel
@testable import KauppaProductsRepository
@testable import KauppaProductsStore
@testable import KauppaProducts

class TestProductsRepository: XCTestCase {

    static var allTests: [(String, (TestProductsRepository) -> () throws -> Void)] {
        return [
            ("Test product creation", testProductCreation),
            ("Test product deletion", testProductDeletion),
            ("Test update of product", testProductUpdate),
            ("Test store function calls", testStoreCalls),
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
        let creation = expectation(description: "Product created")
        let product = ProductData(title: "", subtitle: "", description: "")

        let data = repository.createProduct(data: product)
        XCTAssertNotNil(data)
        XCTAssertEqual(data!.createdOn, data!.updatedAt)
        XCTAssertTrue(store.createCalled)
        XCTAssertNotNil(repository.products[data!.id])
        creation.fulfill()

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    func testProductDeletion() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let deletion = expectation(description: "Product deleted")
        let product = ProductData(title: "", subtitle: "", description: "")

        let data = repository.createProduct(data: product)!
        let isDeleted = repository.deleteProduct(id: data.id)
        XCTAssertTrue(isDeleted)
        XCTAssertTrue(repository.products.isEmpty)
        XCTAssertTrue(store.deleteCalled)
        XCTAssertTrue(store.products.isEmpty)
        deletion.fulfill()

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    func testProductUpdate() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let update = expectation(description: "Product updated")
        var product = ProductData(title: "", subtitle: "", description: "")

        let data = repository.createProduct(data: product)!
        XCTAssertEqual(data.createdOn, data.updatedAt)
        product.title = "Foo"
        let updatedProduct = repository.updateProductData(id: data.id, data: product)!
        // We're just testing the function calls (extensive testing is done in service)
        XCTAssertEqual(updatedProduct.data.title, "Foo")
        XCTAssertTrue(store.updateCalled)
        update.fulfill()

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    func testStoreCalls() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let product = ProductData(title: "", subtitle: "", description: "")
        let data = repository.createProduct(data: product)!
        repository.products = [:]       // clear the repository
        let _ = repository.getProduct(id: data.id)
        XCTAssertEqual(store.getCalled, true)
        store.getCalled = false         // pretend that we never called the store
        let _ = repository.getProduct(id: data.id)
        // store shouldn't be called, because it was recently fetched by the repository
        XCTAssertFalse(store.getCalled)
    }
}
