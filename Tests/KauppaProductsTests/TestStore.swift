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

    public func createNewProduct(productData: Product) throws -> () {
        createCalled = true
        products[productData.id] = productData
        return ()
    }

    public func getProduct(id: UUID) throws -> Product {
        getCalled = true
        guard let product = products[id] else {
            throw ProductsError.invalidProduct
        }

        return product
    }

    public func deleteProduct(id: UUID) throws -> () {
        deleteCalled = true
        if products.removeValue(forKey: id) != nil {
            return ()
        } else {
            throw ProductsError.invalidProduct
        }
    }

    public func updateProduct(productData: Product) throws -> () {
        updateCalled = true
        products[productData.id] = productData
        return ()
    }
}
