import Foundation
import XCTest

import KauppaAccountsModel
@testable import KauppaTaxModel
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
            ("Test product categories", testProductCategories),
        ]
    }

    override func setUp() {
        taxService = TestTaxService()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    /// Test that service supports product creation
    func testProductCreation() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let product = Product(title: "foo", subtitle: "bar", description: "foobar")
        let _ = try! service.createProduct(with: product, from: Address())
    }

    /// Test that service supports product creation with price inclusive of taxes.
    func testProductCreationInclusiveTax() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        taxService.rate = nil
        let service = ProductsService(with: repository, taxService: taxService)
        var data = Product(title: "foo", subtitle: "bar", description: "foobar")
        data.taxInclusive = true
        data.price.value = 10.0

        let product = try! service.createProduct(with: data, from: nil)
        XCTAssertTrue(product.taxInclusive!)
        XCTAssertEqual(product.price.value, 10)
        XCTAssertNil(product.tax)
    }

    /// Test that service supports product deletion
    func testProductDeletion() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let product = Product(title: "foo", subtitle: "bar", description: "foobar")
        let data = try! service.createProduct(with: product, from: Address())
        try! service.deleteProduct(for: data.id!)       // deletion succeeded
    }

    /// Test that service supports updating various product properties (PUT call)
    func testProductUpdate() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let product = Product(title: "Foo",
                                  subtitle: "Bar",
                                  description: "Foobar")
        let data = try! service.createProduct(with: product, from: Address())
        let productId = data.id!

        let anotherProduct = Product(title: "foo", subtitle: "bar", description: "foobar")
        let anotherData = try! service.createProduct(with: anotherProduct, from: Address())
        let anotherId = anotherData.id!
        let randomId = UUID()

        // Prefering JSON data over manually writing all the test cases
        let validTests: [(String, Any)] = [
            ("title", "\"Foobar\""),
            ("subtitle", "\"Baz\""),
            ("description", "\"Foo Bar Baz\""),
            ("overview", "\"Boooooya\""),
            ("tags", ["foo", "bar", "bar"]),
            ("dimensions", "{\"length\": {\"value\": 10.0, \"unit\": \"cm\"}}"),
            ("dimensions", "{\"height\": {\"value\": 1.0, \"unit\": \"m\"}}"),
            ("dimensions", "{\"width\": {\"value\": 0.5, \"unit\": \"mm\"}}"),
            ("weight", "{\"value\": 500.0, \"unit\": \"g\"}"),
            ("color", "\"blue\""),
            ("inventory", 20),
            ("taxCategory", "\"electronics\""),
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
        XCTAssertEqual(updatedProduct.title, "Foobar")
        XCTAssertEqual(updatedProduct.subtitle, "Baz")
        XCTAssertEqual(updatedProduct.description, "Foo Bar Baz")
        XCTAssertEqual(updatedProduct.overview!, "Boooooya")
        XCTAssertEqual(updatedProduct.tags!.inner, ["foo", "bar"])
        XCTAssert(updatedProduct.dimensions!.length!.value == 10.0)
        XCTAssert(updatedProduct.dimensions!.length!.unit == .centimeter)
        XCTAssert(updatedProduct.dimensions!.width!.value == 0.5)
        XCTAssert(updatedProduct.dimensions!.width!.unit == .millimeter)
        XCTAssert(updatedProduct.dimensions!.height!.value == 1.0)
        XCTAssert(updatedProduct.dimensions!.height!.unit == .meter)
        XCTAssert(updatedProduct.weight!.value == 500.0)
        XCTAssert(updatedProduct.weight!.unit == .gram)
        XCTAssertEqual(updatedProduct.color!, "blue")
        XCTAssertEqual(updatedProduct.inventory, 20)
        XCTAssertEqual(updatedProduct.images!.inner,
                       ["data:image/gif;base64,foobar", "data:image/gif;base64,foo"])
        XCTAssertEqual(updatedProduct.price.value, 30.0)
        XCTAssertEqual(updatedProduct.price.unit, .usd)
        XCTAssertEqual(updatedProduct.taxCategory!, "electronics")
        XCTAssert(updatedProduct.createdOn! < updatedProduct.updatedAt!)
        XCTAssertEqual(updatedProduct.variantId!, anotherId)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    /// Test that product inclusive of tax doesn't calculate tax.
    func testProductUpdateInclusiveTax() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        var rate = TaxRate()
        rate.general = 18.0
        rate.categories["food"] = 12.0
        taxService.rate = rate
        let service = ProductsService(with: repository, taxService: taxService)
        var data = Product(title: "foo", subtitle: "bar", description: "foobar")
        data.price = UnitMeasurement(value: 10.0, unit: .usd)

        var product = try! service.createProduct(with: data, from: Address())
        XCTAssertNotNil(product.tax)
        XCTAssertEqual(product.tax!.rate, 18.0)
        let tax = product.tax!.total.value
        XCTAssertTrue(tax > 1.79999999999 && tax < 1.80000000001)
        XCTAssertNil(product.tax!.category)
        XCTAssertFalse(product.taxInclusive!)

        var patch = ProductPatch()
        patch.taxCategory = "food"
        product = try! service.updateProduct(for: product.id!, with: patch, from: Address())
        XCTAssertNotNil(product.tax)
        XCTAssertEqual(product.tax!.category!, "food")
        XCTAssertEqual(product.tax!.rate, 12.0)
        XCTAssertEqual(product.tax!.total.value, 1.2)

        patch.taxInclusive = true
        product = try! service.updateProduct(for: product.id!, with: patch, from: Address())
        XCTAssertTrue(product.taxInclusive!)
        XCTAssertNil(product.tax)
    }

    /// Test that service supports adding items to collection properties.
    func testPropertyAddition() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let product = Product(title: "foo", subtitle: "bar", description: "foobar")
        let data = try! service.createProduct(with: product, from: Address())
        XCTAssertEqual(data.images!.inner, [])  // no images

        var patch = ProductPropertyAdditionPatch()
        patch.image = "data:image/png;base64,foobar"
        let updatedProduct = try! service.addProductProperty(for: data.id!, with: patch,
                                                             from: Address())
        // image should've been added
        XCTAssertEqual(updatedProduct.images!.inner, ["data:image/png;base64,foobar"])
    }

    /// Test that service supports resetting individual product properties.
    func testPropertyDeletion() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        var product = Product(title: "foo", subtitle: "bar", description: "foobar")
        // set all additional attributes required for testing
        product.images = ArraySet(["data:image/png;base64,bar", "data:image/png;base64,baz"])
        product.color = "#000"
        product.weight = UnitMeasurement(value: 50.0, unit: .gram)
        var dimensions = Dimensions()
        dimensions.length = UnitMeasurement(value: 10.0, unit: .centimeter)
        product.dimensions = dimensions
        product.taxCategory = "food"
        // variant is checked in `TestProductVariants`
        let data = try! service.createProduct(with: product, from: Address())

        var patch = ProductPropertyDeletionPatch()
        patch.removeTaxCategory = true
        patch.removeColor = true
        patch.removeDimensions = true
        patch.removeWeight = true
        patch.removeImageAt = 0     // remove image at zero'th index
        let updatedProduct = try! service.deleteProductProperty(for: data.id!, with: patch,
                                                                from: Address())
        XCTAssertEqual(updatedProduct.images!.inner, ["data:image/png;base64,baz"])
        XCTAssertNil(updatedProduct.dimensions)
        XCTAssertNil(updatedProduct.taxCategory)
        XCTAssertNil(updatedProduct.color)
        XCTAssertNil(updatedProduct.weight)
    }

    /// Same as product creation - for collections. This checks whether the supplied products exist.
    func testCollectionCreation() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        var productData = Product(title: "foo", subtitle: "bar", description: "foobar")
        let product1 = try! service.createProduct(with: productData, from: Address())
        productData.color = "#000"
        let product2 = try! service.createProduct(with: productData, from: Address())

        let collection = ProductCollectionData(name: "foo", description: "bar",
                                               products: [product1.id!, product2.id!])
        let data = try? service.createCollection(with: collection)
        XCTAssertNotNil(data)
    }

    /// Test that service should ignore collection creation with invalid products.
    func testCollectionInvalidProduct() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let collection = ProductCollectionData(name: "foo", description: "bar", products: [UUID()])
        do {
            let _ = try service.createCollection(with: collection)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.invalidProductId)
        }
    }

    /// Test that service supports deleting collections.
    func testCollectionDeletion() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let collection = ProductCollectionData(name: "foo", description: "bar", products: [])
        let data = try! service.createCollection(with: collection)
        let _ = try! service.deleteCollection(for: data.id)
    }

    /// Test that service supports updating collections (PUT call). Invalid products should throw errors.
    func testCollectionUpdate() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        let productData = Product(title: "foo", subtitle: "bar", description: "foobar")
        let product1 = try! service.createProduct(with: productData, from: Address())
        let collection = ProductCollectionData(name: "foo", description: "bar", products: [])
        let data = try! service.createCollection(with: collection)
        XCTAssertTrue(data.data.products.isEmpty)

        var patch = ProductCollectionPatch()
        patch.name = "foo"
        patch.description = "foobar"
        patch.products = [product1.id!]
        let updatedCollection = try! service.updateCollection(for: data.id, with: patch)
        XCTAssertTrue(updatedCollection.createdOn != updatedCollection.updatedAt)
        XCTAssertEqual(updatedCollection.data.name, "foo")
        XCTAssertEqual(updatedCollection.data.description, "foobar")
        XCTAssertEqual(updatedCollection.data.products, [product1.id!])

        // also check invalid product update
        patch.products = [UUID()]
        do {
            let _ = try service.updateCollection(for: data.id, with: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.invalidProductId)
        }
    }

    /// Test that service supports adding valid products to collections.
    func testCollectionAdd() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        var productData = Product(title: "foo", subtitle: "bar", description: "foobar")
        let product1 = try! service.createProduct(with: productData, from: Address())
        productData.color = "#FFF"
        let product2 = try! service.createProduct(with: productData, from: Address())
        let collection = ProductCollectionData(name: "foo", description: "bar", products: [])
        let data = try! service.createCollection(with: collection)

        var patch = ProductCollectionItemPatch()
        patch.product = product1.id
        patch.products = [product2.id!, product2.id!, product2.id!]     // duplicate
        let updatedCollection = try! service.addProduct(to: data.id, using: patch)
        XCTAssertEqual(updatedCollection.data.products, [product1.id!, product2.id!])   // only two exist
        patch.product = UUID()  // random ID - no product
        do {
            let _ = try service.addProduct(to: data.id, using: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.invalidProductId)
        }
    }

    /// Test that service supports product removal from collections.
    func testCollectionRemove() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        var productData = Product(title: "foo", subtitle: "bar", description: "foobar")
        let product1 = try! service.createProduct(with: productData, from: Address())
        productData.color = "#fff"
        let product2 = try! service.createProduct(with: productData, from: Address())
        let collection = ProductCollectionData(name: "foo", description: "bar",
                                               products: [product1.id!, product2.id!])
        let data = try! service.createCollection(with: collection)

        var patch = ProductCollectionItemPatch()
        patch.product = product1.id
        // We've already validated products before inserting into a collection.
        // So, deletion only checks if the ID exists in the collection, and ignores otherwise.
        patch.products = [product2.id!, UUID()]
        let updatedCollection = try! service.removeProduct(from: data.id, using: patch)
        XCTAssertEqual(updatedCollection.data.products, [])
    }

    /// Test that the service supports creation and re-using categories.
    func testProductCategories() {
        let store = TestStore()
        let repository = ProductsRepository(with: store)
        let service = ProductsService(with: repository, taxService: taxService)
        var productData = Product(title: "foo", subtitle: "bar", description: "foobar")
        productData.categories = [
            Category(name: "Foo"),
            Category(name: "foo"),      // category already exists - will be skipped
            Category(name: "bar"),
            Category(name: ""),         // category name empty - will be skipped
        ]

        // This will create new categories.
        let product1 = try! service.createProduct(with: productData, from: nil)
        XCTAssertEqual(product1.categories!.count, 2)
        XCTAssertNotNil(product1.categories![0].id)
        XCTAssertEqual(product1.categories![0].name!, "foo")
        XCTAssertNotNil(product1.categories![1].id)
        XCTAssertEqual(product1.categories![1].name!, "bar")

        // This will re-use those categories.
        let product2 = try! service.createProduct(with: productData, from: nil)
        productData.categories![0].id = product1.categories![0].id
        XCTAssertEqual(product2.categories!.count, 2)
        XCTAssertEqual(product2.categories![0].id!, product1.categories![0].id!)
        XCTAssertEqual(product2.categories![1].id!, product1.categories![1].id!)

        // This will update product data with the same categories. Re-using happens again.
        var patch = ProductPatch()
        patch.categories = productData.categories
        let updatedProduct1 = try! service.updateProduct(for: product1.id!, with: patch, from: nil)
        XCTAssertEqual(updatedProduct1.categories!.count, 2)
        XCTAssertEqual(updatedProduct1.categories![0].id!, product1.categories![0].id!)
        XCTAssertEqual(updatedProduct1.categories![1].id!, product1.categories![1].id!)
    }
}
