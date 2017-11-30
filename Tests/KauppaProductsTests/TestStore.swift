import Foundation

@testable import KauppaProductsStore
@testable import KauppaProductsModel

public class TestStore: ProductsStore {
    public var products = [UUID: Product]()

    // Variables to indicate the count of function calls
    public var createCalled = 0
    public var getCalled = 0
    public var deleteCalled = 0
    public var updateCalled = 0

    public func createNewProduct(productData: Product) {
        createCalled += 1
        products[productData.id] = productData
    }

    public func getProduct(id: UUID) -> Product? {
        getCalled += 1
        return products[id]
    }

    public func deleteProduct(id: UUID) -> Bool {
        deleteCalled += 1
        return products.removeValue(forKey: id) != nil
    }

    public func updateProduct(productData: Product) {
        updateCalled += 1
        products[productData.id] = productData
    }
}
