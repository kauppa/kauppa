import Foundation

@testable import KauppaProductsStore
@testable import KauppaProductsModel

public class TestStore: ProductsStorable {
    public var products = [UUID: Product]()
    public var collections = [UUID: ProductCollection]()
    public var attributes = [UUID: Attribute]()

    // Variables to indicate the count of function calls
    public var createCalled = false
    public var getCalled = false
    public var deleteCalled = false
    public var updateCalled = false

    public var collectionCreateCalled = false
    public var collectionUpdateCalled = false
    public var collectionGetCalled = false
    public var collectionDeleteCalled = false

    public var attributeCreationCalled = false
    public var attributeGetCalled = false

    public func createNewProduct(with data: Product) throws -> () {
        createCalled = true
        products[data.id] = data
    }

    public func getProduct(for id: UUID) throws -> Product {
        getCalled = true
        guard let product = products[id] else {
            throw ProductsError.invalidProduct
        }

        return product
    }

    public func deleteProduct(for id: UUID) throws -> () {
        deleteCalled = true
        if products.removeValue(forKey: id) != nil {
            return
        } else {
            throw ProductsError.invalidProduct
        }
    }

    public func updateProduct(with data: Product) throws -> () {
        updateCalled = true
        products[data.id] = data
    }

    public func createNewCollection(with data: ProductCollection) throws -> () {
        collectionCreateCalled = true
        collections[data.id] = data
    }

    public func getCollection(for id: UUID) throws -> ProductCollection {
        collectionGetCalled = true
        guard let collection = collections[id] else {
            throw ProductsError.invalidCollection
        }

        return collection
    }

    public func updateCollection(with data: ProductCollection) throws -> () {
        collectionUpdateCalled = true
        collections[data.id] = data
    }

    public func deleteCollection(for id: UUID) throws -> () {
        collectionDeleteCalled = true
        if collections.removeValue(forKey: id) != nil {
            return
        } else {
            throw ProductsError.invalidCollection
        }
    }

    public func createAttribute(with data: Attribute) throws -> () {
        attributeCreationCalled = true
        attributes[data.id] = data
    }

    public func getAttribute(for id: UUID) throws -> Attribute {
        attributeGetCalled = true
        guard let attribute = attributes[id] else {
            throw ProductsError.invalidAttribute
        }

        return attribute
    }
}
