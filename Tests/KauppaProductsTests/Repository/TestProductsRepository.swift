import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaProductsModel
@testable import KauppaProductsRepository
@testable import KauppaProductsStore

class TestProductsRepository: XCTestCase {

    static var allTests: [(String, (TestProductsRepository) -> () throws -> Void)] {
        return [
            ("Test product creation", testProductCreation),
            ("Test product deletion", testProductDeletion),
            ("Test update of product", testProductUpdate),
            ("Test collection creation", testCollectionCreation),
            ("Test collection update", testCollectionUpdate),
            ("Test collection deletion", testCollectionDeletion),
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
        var product = ProductData(title: "", subtitle: "", description: "")
        product.category = "foobar"
        product.tags = ArraySet(["foo", "bar"])

        let data = try? repository.createProduct(data: product)
        XCTAssertNotNil(data)
        // These two timestamps should be the same in creation
        XCTAssertEqual(data!.createdOn, data!.updatedAt)
        XCTAssertTrue(store.createCalled)   // store has been called for creation
        XCTAssertTrue(repository.categories.contains("foobar"))   // has category
        XCTAssertEqual(repository.tags, ["foo", "bar"])
        XCTAssertNotNil(repository.products[data!.id])  // repository now has product data
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

        let data = try! repository.createProduct(data: product)
        let result: ()? = try? repository.deleteProduct(id: data.id)
        XCTAssertNotNil(result)
        XCTAssertTrue(repository.products.isEmpty)      // repository shouldn't have the product
        XCTAssertTrue(store.deleteCalled)       // delete should've been called in store (by repository)
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

        let data = try! repository.createProduct(data: product)
        XCTAssertEqual(data.createdOn, data.updatedAt)
        product.title = "Foo"
        let updatedProduct = try! repository.updateProductData(id: data.id, data: product)
        // We're just testing the function calls (extensive testing is done in service)
        XCTAssertEqual(updatedProduct.data.title, "Foo")
        XCTAssertTrue(store.updateCalled)   // update called on store
        update.fulfill()

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    func testCollectionCreation() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        let product1 = try! repository.createProduct(data: productData)
        productData.color = "black"
        let product2 = try! repository.createProduct(data: productData)

        let collection = ProductCollectionData(name: "", description: "",
                                               products: ArraySet([product1.id, product2.id]))
        let data = try! repository.createCollection(with: collection)
        // These two timestamps should be the same in creation
        XCTAssertEqual(data.createdOn, data.updatedAt)
        XCTAssertTrue(store.collectionCreateCalled)     // store has been called for creation
        XCTAssertNotNil(repository.collections[data.id])    // repository now has collection data
    }

    func testCollectionUpdate() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        var collection = ProductCollectionData(name: "", description: "", products: ArraySet())
        let data = try! repository.createCollection(with: collection)
        collection.name = "foo"
        let updatedCollection = try! repository.updateCollectionData(id: data.id, data: collection)
        // We're just testing the function calls (extensive testing is done in service)
        XCTAssertEqual(updatedCollection.data.name, "foo")
        XCTAssertTrue(store.collectionUpdateCalled)     // update called on store
    }

    func testCollectionDeletion() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let collection = ProductCollectionData(name: "", description: "", products: ArraySet())
        let data = try! repository.createCollection(with: collection)
        let result: ()? = try? repository.deleteCollection(id: data.id)
        XCTAssertNotNil(result)
        XCTAssertTrue(repository.collections.isEmpty)   // repository shouldn't have the collection
        XCTAssertTrue(store.collectionDeleteCalled)     // delete should've been called in store
    }

    func testStoreCalls() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let productData = ProductData(title: "", subtitle: "", description: "")
        let product = try! repository.createProduct(data: productData)
        repository.products = [:]       // clear the repository
        let _ = try? repository.getProduct(id: product.id)
        XCTAssertTrue(store.getCalled)  // this should've called the store
        store.getCalled = false         // now, pretend that we never called the store
        let _ = try? repository.getProduct(id: product.id)
        // store shouldn't be called, because it was recently fetched by the repository
        XCTAssertFalse(store.getCalled)

        let collection = ProductCollectionData(name: "", description: "",
                                               products: ArraySet([product.id]))
        let data = try! repository.createCollection(with: collection)
        repository.collections = [:]    // clear the repository
        let _ = try? repository.getCollection(id: data.id)
        XCTAssertTrue(store.collectionGetCalled)    // store should've been called
        store.collectionGetCalled = false       // pretend that store hasn't been called
        let _ = try? repository.getCollection(id: data.id)
        // store shouldn't be called, because it was recently fetched by the repository
        XCTAssertFalse(store.collectionGetCalled)
    }
}
