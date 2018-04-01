import Foundation
import XCTest

import KauppaAccountsModel
import KauppaTaxModel
@testable import KauppaCore
@testable import KauppaProductsModel
@testable import KauppaProductsRepository
@testable import KauppaProductsService

class TestProductsService: XCTestCase {
    var taxService = TestTaxService()

    static var allTests: [(String, (TestProductsService) -> () throws -> Void)] {
        return [
            ("Test product creation", testProductCreation),
            ("Test product creation - inclusive tax", testProductCreationInclusiveTax),
            ("Test product deletion", testProductDeletion),
            ("Test update of product", testProductUpdate),
            ("Test product price update - inclusive tax", testProductUpdateInclusiveTax),
            ("Test individual property deletion", testPropertyDeletion),
            ("Test individual property addition", testPropertyAddition),
            ("Test collection creation", testCollectionCreation),
            ("Test invalid product in collection", testCollectionInvalidProduct),
            ("Test collection deletion", testCollectionDeletion),
            ("Test collection update", testCollectionUpdate),
            ("Test collection add product(s)", testCollectionAdd),
            ("Test collection remove product(s)", testCollectionRemove),
        ]
    }

    override func setUp() {
        taxService = TestTaxService()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Service supports product creation
    func testProductCreation() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let product = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let _ = try! service.createProduct(with: product, from: Address())
    }

    // Service supports product creation with price inclusive of taxes.
    func testProductCreationInclusiveTax() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        var rate = TaxRate()
        rate.general = 10.0
        rate.categories["food"] = 8.0
        taxService.rate = rate
        let service = ProductsService(with: repository, taxService: taxService)
        var data = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        data.taxInclusive = true
        data.price.value = 10.0

        var product = try! service.createProduct(with: data, from: Address())
        XCTAssertFalse(product.data.taxInclusive)
        var price = product.data.price.value
        XCTAssertTrue(price > 9.090909 && price < 9.09091)
        XCTAssertNil(product.data.tax!.category)
        XCTAssertEqual(product.data.tax!.rate, 10.0)
        var tax = product.data.tax!.total.value
        XCTAssertTrue(tax > 0.9090909 && tax < 0.909091)

        data.category = "food"      // matching category - applies associated tax rate
        product = try! service.createProduct(with: data, from: Address())
        XCTAssertFalse(product.data.taxInclusive)
        price = product.data.price.value
        XCTAssertTrue(price > 9.259259 && price < 9.25926)
        XCTAssertEqual(product.data.tax!.category!, "food")
        XCTAssertEqual(product.data.tax!.rate, 8.0)
        tax = product.data.tax!.total.value
        XCTAssertTrue(tax > 0.7407407 && tax < 0.7407408)
    }

    // Service supports product deletion
    func testProductDeletion() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let product = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let data = try! service.createProduct(with: product, from: Address())
        try! service.deleteProduct(for: data.id)    // deletion succeeded
    }

    // Service supports updating various product properties (PUT call)
    func testProductUpdate() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let product = ProductData(title: "Foo",
                                  subtitle: "Bar",
                                  description: "Foobar")
        let data = try! service.createProduct(with: product, from: Address())
        let productId = data.id

        let anotherProduct = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let anotherData = try! service.createProduct(with: anotherProduct, from: Address())
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
            ("price", "{\"value\": 30.0, \"unit\": \"USD\"}"),
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
            let result = try? service.updateProduct(for: productId, with: data, from: Address())
            if i < validTests.count {
                XCTAssertNotNil(result)
            } else {
                XCTAssertNil(result)
            }

            expectation_.fulfill()
            i += 1
        }

        // All successful updates
        let updatedProduct = try! service.getProduct(for: productId, from: Address())
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
        XCTAssertEqual(updatedProduct.data.price.value, 30.0)
        XCTAssertEqual(updatedProduct.data.price.unit, .usd)
        XCTAssertEqual(updatedProduct.data.category, "electronics")
        XCTAssert(updatedProduct.createdOn < updatedProduct.updatedAt)
        XCTAssertEqual(updatedProduct.data.variantId, anotherId)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    func testProductUpdateInclusiveTax() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        var rate = TaxRate()
        rate.general = 18.0
        rate.categories["food"] = 12.0
        taxService.rate = rate
        let service = ProductsService(with: repository, taxService: taxService)
        let data = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        var product = try! service.createProduct(with: data, from: Address())

        var patch = ProductPatch()
        patch.price = UnitMeasurement(value: 10.0, unit: .usd)
        patch.taxInclusive = true
        product = try! service.updateProduct(for: product.id, with: patch, from: Address())
        var price = product.data.price.value
        XCTAssertTrue(price > 8.47457627 && price < 8.47457628)
        XCTAssertNil(product.data.tax!.category)
        XCTAssertEqual(product.data.tax!.rate, 18.0)
        var tax = product.data.tax!.total.value
        XCTAssertTrue(tax > 1.525423728 && tax < 1.525423729)

        patch.category = "food"
        product = try! service.updateProduct(for: product.id, with: patch, from: Address())
        price = product.data.price.value
        XCTAssertTrue(price > 8.92857142 && price < 8.92857143)
        XCTAssertEqual(product.data.tax!.category!, "food")
        XCTAssertEqual(product.data.tax!.rate, 12.0)
        tax = product.data.tax!.total.value
        XCTAssertTrue(tax > 1.071428571 && tax < 1.071428572)
    }

    // Service supports adding items to collection properties.
    func testPropertyAddition() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let product = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let data = try! service.createProduct(with: product, from: Address())
        XCTAssertEqual(data.data.images.inner, [])      // no images

        var patch = ProductPropertyAdditionPatch()
        patch.image = "data:image/png;base64,foobar"
        let updatedProduct = try! service.addProductProperty(for: data.id, with: patch,
                                                             from: Address())
        // image should've been added
        XCTAssertEqual(updatedProduct.data.images.inner, ["data:image/png;base64,foobar"])
    }

    // Service supports resetting individual product properties.
    func testPropertyDeletion() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        var product = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        // set all additional attributes required for testing
        product.images.inner = ["data:image/png;base64,bar", "data:image/png;base64,baz"]
        product.color = "#000"
        product.weight = UnitMeasurement(value: 50.0, unit: .gram)
        var size = Size()
        size.length = UnitMeasurement(value: 10.0, unit: .centimeter)
        product.size = size
        product.category = "food"
        // variant is checked in `TestProductVariants`
        let data = try! service.createProduct(with: product, from: Address())

        var patch = ProductPropertyDeletionPatch()
        patch.removeCategory = true
        patch.removeColor = true
        patch.removeSize = true
        patch.removeWeight = true
        patch.removeImageAt = 0     // remove image at zero'th index
        let updatedProduct = try! service.deleteProductProperty(for: data.id, with: patch,
                                                                from: Address())
        XCTAssertEqual(updatedProduct.data.images.inner, ["data:image/png;base64,baz"])
        XCTAssertNil(updatedProduct.data.size)
        XCTAssertNil(updatedProduct.data.category)
        XCTAssertNil(updatedProduct.data.color)
        XCTAssertNil(updatedProduct.data.weight)
    }

    // Same as product creation - for collections. This checks whether the supplied products exist.
    func testCollectionCreation() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        var productData = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let product1 = try! service.createProduct(with: productData, from: Address())
        productData.color = "#000"
        let product2 = try! service.createProduct(with: productData, from: Address())

        let collection = ProductCollectionData(name: "foo", description: "bar",
                                               products: [product1.id, product2.id])
        let data = try? service.createCollection(with: collection)
        XCTAssertNotNil(data)
    }

    // Service should ignore collection creation with invalid products.
    func testCollectionInvalidProduct() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let collection = ProductCollectionData(name: "foo", description: "bar", products: [UUID()])
        do {
            let _ = try service.createCollection(with: collection)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ProductsError, ProductsError.invalidProduct)
        }
    }

    // Service supports deleting collections.
    func testCollectionDeletion() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let collection = ProductCollectionData(name: "foo", description: "bar", products: [])
        let data = try! service.createCollection(with: collection)
        let _ = try! service.deleteCollection(for: data.id)
    }

    // Service supports updating collections (PUT call). Invalid products should throw errors.
    func testCollectionUpdate() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let productData = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let product1 = try! service.createProduct(with: productData, from: Address())
        let collection = ProductCollectionData(name: "foo", description: "bar", products: [])
        let data = try! service.createCollection(with: collection)
        XCTAssertTrue(data.data.products.isEmpty)

        var patch = ProductCollectionPatch()
        patch.name = "foo"
        patch.description = "foobar"
        patch.products = [product1.id]
        let updatedCollection = try! service.updateCollection(for: data.id, with: patch)
        XCTAssertTrue(updatedCollection.createdOn != updatedCollection.updatedAt)
        XCTAssertEqual(updatedCollection.data.name, "foo")
        XCTAssertEqual(updatedCollection.data.description, "foobar")
        XCTAssertEqual(updatedCollection.data.products, [product1.id])

        // also check invalid product update
        patch.products = [UUID()]
        do {
            let _ = try service.updateCollection(for: data.id, with: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ProductsError, ProductsError.invalidProduct)
        }
    }

    // Service supports adding valid products to collections.
    func testCollectionAdd() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        var productData = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let product1 = try! service.createProduct(with: productData, from: Address())
        productData.color = "#FFF"
        let product2 = try! service.createProduct(with: productData, from: Address())
        let collection = ProductCollectionData(name: "foo", description: "bar", products: [])
        let data = try! service.createCollection(with: collection)

        var patch = ProductCollectionItemPatch()
        patch.product = product1.id
        patch.products = [product2.id, product2.id, product2.id]    // duplicate
        let updatedCollection = try! service.addProduct(to: data.id, using: patch)
        XCTAssertEqual(updatedCollection.data.products, [product1.id, product2.id])     // only two exist
        patch.product = UUID()  // random ID - no product
        do {
            let _ = try service.addProduct(to: data.id, using: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ProductsError, ProductsError.invalidProduct)
        }
    }

    // Service supports product removal from collections.
    func testCollectionRemove() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        var productData = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let product1 = try! service.createProduct(with: productData, from: Address())
        productData.color = "#fff"
        let product2 = try! service.createProduct(with: productData, from: Address())
        let collection = ProductCollectionData(name: "foo", description: "bar",
                                               products: [product1.id, product2.id])
        let data = try! service.createCollection(with: collection)

        var patch = ProductCollectionItemPatch()
        patch.product = product1.id
        // We've already validated products before inserting into a collection.
        // So, deletion only checks if the ID exists in the collection, and ignores otherwise.
        patch.products = [product2.id, UUID()]
        let updatedCollection = try! service.removeProduct(from: data.id, using: patch)
        XCTAssertEqual(updatedCollection.data.products, [])
    }
}
