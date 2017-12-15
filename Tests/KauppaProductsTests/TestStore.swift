import Foundation

@testable import KauppaProductsStore
@testable import KauppaProductsModel

public class TestStore: ProductsStorable {
    public var products = [UUID: Product]()
    public var collections = [UUID: ProductCollection]()

    // Variables to indicate the count of function calls
    public var createCalled = false
    public var getCalled = false
    public var deleteCalled = false
    public var updateCalled = false
    public var collectionCreateCalled = false
    public var collectionUpdateCalled = false
    public var collectionGetCalled = false
    public var collectionDeleteCalled = false

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

    public func createNewCollection(data: ProductCollection) throws -> () {
        collectionCreateCalled = true
        collections[data.id] = data
        return ()
    }

    public func getCollection(id: UUID) throws -> ProductCollection {
        collectionGetCalled = true
        guard let collection = collections[id] else {
            throw ProductsError.invalidCollection
        }

        return collection
    }

    public func updateCollection(data: ProductCollection) throws -> () {
        collectionUpdateCalled = true
        collections[data.id] = data
        return ()
    }

    public func deleteCollection(id: UUID) throws -> () {
        collectionDeleteCalled = true
        if collections.removeValue(forKey: id) != nil {
            return ()
        } else {
            throw ProductsError.invalidCollection
        }
    }
}
