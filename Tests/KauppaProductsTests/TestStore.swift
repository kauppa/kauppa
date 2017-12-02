import Foundation

@testable import KauppaProductsStore
@testable import KauppaProductsModel

public class TestStore: ProductsStore {
    public var products = [UUID: Product]()

    // Variables to indicate the count of function calls
    public var createCalled = false
    public var getCalled = false
    public var deleteCalled = false
    public var updateCalled = false

    public func createNewProduct(productData: Product) {
        createCalled = true
        products[productData.id] = productData
    }

    public func getProduct(id: UUID) -> Product? {
        getCalled = true
        return products[id]
    }

    public func deleteProduct(id: UUID) -> Bool {
        deleteCalled = true
        return products.removeValue(forKey: id) != nil
    }

    public func updateProduct(productData: Product) {
        updateCalled = true
        products[productData.id] = productData
    }
}
