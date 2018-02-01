import Foundation
import XCTest

@testable import KauppaProductsModel
@testable import KauppaProductsRepository
@testable import KauppaProductsService

class TestProductVariants: XCTestCase {

    static var allTests: [(String, (TestProductVariants) -> () throws -> Void)] {
        return [
            ("Test product creation with variant", testProductCreationWithVariant),
            ("Test product creation with invalid variant", testProductCreationWithInvalidVariant),
            ("Test product update with variant", testProductUpdateWithVariant),
            ("Test product creation with cross-referencing variants", testProductCreationWithCrossReferencingVariant),
            ("Test product update with cross-referencing variants", testProductUpdateWithCrossReferencingVariants),
            ("Test variant removal", testVariantRemoval),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Service supports creating variant of a product. This should automatically add
    // the product's ID to the parent's `variants` list.
    func testProductCreationWithVariant() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        var productData = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let parentProduct = try! service.createProduct(data: productData)
        // imitate another product referencing the previous one
        productData.variantId = parentProduct.id
        let childVariant = try! service.createProduct(data: productData)
        let parent = try! service.getProduct(id: parentProduct.id)
        // should automatically add the variant to parent's list
        XCTAssertEqual(parent.data.variants, [childVariant.id])
        XCTAssertNotNil(childVariant.data.variantId)
    }

    // Service shouldn't allow creating variant when the parent doesn't exist.
    func testProductCreationWithInvalidVariant() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        var productData = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        productData.variantId = UUID()      // random UUID
        let product = try! service.createProduct(data: productData)
        XCTAssertNil(product.data.variantId)    // invalid variant - ignored
    }

    // When a product is updated with `variantId`, it should add the product's ID to
    // the parent product's `variants` list.
    func testProductUpdateWithVariant() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        let productData = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let parentProduct = try! service.createProduct(data: productData)

        let childVariant = try! service.createProduct(data: productData)
        // patch the variant referencing the parent product
        var patch = ProductPatch()
        patch.variantId = parentProduct.id
        let _ = try! service.updateProduct(id: childVariant.id, data: patch)

        let parent = try! service.getProduct(id: parentProduct.id)
        // should automatically add the variant to parent's list
        XCTAssertEqual(parent.data.variants, [childVariant.id])
        let child = try! service.getProduct(id: childVariant.id)
        XCTAssertNotNil(child.data.variantId)   // child should now reference parent
    }

    // If a product is created with `variantId` pointing to another variant, then the `variantId`
    // is changed to the parent's ID, and the parent's list is updated.
    func testProductCreationWithCrossReferencingVariant() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        var productData = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let parentProduct = try! service.createProduct(data: productData)

        /// create a variant
        productData.variantId = parentProduct.id
        let firstChild = try! service.createProduct(data: productData)

        /// For another variant, we're referencing the variant we just created
        productData.variantId = firstChild.id
        let secondChild = try! service.createProduct(data: productData)

        let parent = try! service.getProduct(id: parentProduct.id)
        // If we check the parent, we'll see that it has both the variants
        XCTAssertEqual(parent.data.variants, [firstChild.id, secondChild.id])
        // second variant should reference parent directly
        let child2 = try! service.getProduct(id: secondChild.id)
        XCTAssertEqual(child2.data.variantId, parent.id)
        let child1 = try! service.getProduct(id: firstChild.id)
        // first variant shouldn't have any variants
        XCTAssertEqual(child1.data.variants, [])
    }

    // The same applies for updating product with `variantId` referencing another variant.
    func testProductUpdateWithCrossReferencingVariants() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        let productData = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        let parentProduct = try! service.createProduct(data: productData)
        let firstChild = try! service.createProduct(data: productData)
        let secondChild = try! service.createProduct(data: productData)

        // Make the second product a variant of the first
        var patch = ProductPatch()
        patch.variantId = parentProduct.id
        let _ = try! service.updateProduct(id: firstChild.id, data: patch)
        let child1 = try! service.getProduct(id: firstChild.id)
        // check that the data has been reflected
        XCTAssertEqual(child1.data.variantId, parentProduct.id)

        // Make the third product variant of the second
        patch.variantId = firstChild.id
        let _ = try! service.updateProduct(id: secondChild.id, data: patch)
        let child2 = try! service.getProduct(id: secondChild.id)
        // The variant should reference the actual parent
        XCTAssertEqual(child2.data.variantId, parentProduct.id)

        // Parent should have all the variants now
        let parent = try! service.getProduct(id: parentProduct.id)
        XCTAssertEqual(parent.data.variants, [firstChild.id, secondChild.id])
    }

    // Removing a variant also removes the variant from the product's `variants` list.
    func testVariantRemoval() {
        let store = TestStore()
        let repository = ProductsRepository(withStore: store)
        let service = ProductsService(withRepository: repository)
        var productData = ProductData(title: "foo", subtitle: "bar", description: "foobar")
        productData.color = "#000"
        let parentProduct = try! service.createProduct(data: productData)

        productData.color = "#fff"
        productData.variantId = parentProduct.id
        let childVariant = try! service.createProduct(data: productData)
        let parent = try! service.getProduct(id: parentProduct.id)
        XCTAssertEqual(parent.data.variants, [childVariant.id])     // child has been added to parent

        var patch = ProductPropertyDeletionPatch()
        patch.removeVariant = true
        let updatedChild = try! service.deleteProductProperty(id: childVariant.id, data: patch)
        XCTAssertNil(updatedChild.data.variantId)   // variant field has been reset
        let updatedParent = try! service.getProduct(id: parentProduct.id)
        XCTAssertEqual(updatedParent.data.variants, [])     // child removed
    }
}
