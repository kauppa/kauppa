import Foundation
import XCTest

import KauppaProductsClient
import KauppaProductsModel

public typealias ProductsCallback = (ProductPatch) -> Void

public class TestProductsService: ProductsServiceCallable {
    var products = [UUID: Product]()
    var callbacks = [UUID: ProductsCallback]()

    public func createProduct(data: ProductData) throws -> Product {
        let id = UUID()
        let date = Date()
        products[id] = Product(id: id, createdOn: date, updatedAt: date, data: data)
        return products[id]!
    }

    public func getProduct(id: UUID) throws -> Product {
        guard let product = products[id] else {
            throw ProductsError.invalidProduct
        }

        return product
    }

    // NOTE: Not meant to be called by orders
    public func deleteProduct(id: UUID) throws -> () {
        throw ProductsError.invalidProduct
    }

    public func updateProduct(id: UUID, data: ProductPatch) throws -> Product {
        if let callback = callbacks[id] {
            callback(data)
        }

        return try getProduct(id: id)   // This is just a stub
    }

    // NOTE: Not meant to be called by orders
    public func addProductProperty(id: UUID, data: ProductPropertyAdditionPatch) throws -> Product {
        throw ProductsError.invalidProduct
    }

    // NOTE: Not meant to be called by orders
    public func deleteProductProperty(id: UUID, data: ProductPropertyDeletionPatch) throws -> Product {
        throw ProductsError.invalidProduct
    }

    // NOTE: Not meant to be called by orders
    public func createCollection(data: ProductCollectionData) throws -> ProductCollection {
        throw ProductsError.invalidCollection
    }

    // NOTE: Not meant to be called by orders
    public func updateCollection(id: UUID, data: ProductCollectionPatch) throws -> ProductCollection {
        throw ProductsError.invalidCollection
    }

    // NOTE: Not meant to be called by orders
    public func deleteCollection(id: UUID) throws -> () {
        throw ProductsError.invalidCollection
    }

    // NOTE: Not meant to be called by orders
    public func addProduct(toCollection id: UUID, data: ProductCollectionItemPatch) throws -> ProductCollection {
        throw ProductsError.invalidCollection
    }

    // NOTE: Not meant to be called by orders
    public func removeProduct(fromCollection id: UUID, data: ProductCollectionItemPatch) throws -> ProductCollection {
        throw ProductsError.invalidCollection
    }
}
