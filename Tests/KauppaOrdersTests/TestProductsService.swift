import Foundation
import XCTest

import KauppaAccountsModel
import KauppaProductsClient
import KauppaProductsModel

public typealias ProductsCallback = (ProductPatch) -> Void

public class TestProductsService: ProductsServiceCallable {
    var products = [UUID: Product]()
    var callbacks = [UUID: ProductsCallback]()

    public func createProduct(with data: ProductData, from address: Address) throws -> Product {
        let product = Product(data: data)
        products[product.id] = product
        return product
    }

    public func getProduct(for id: UUID, from address: Address) throws -> Product {
        guard let product = products[id] else {
            throw ProductsError.invalidProduct
        }

        return product
    }

    // NOTE: Not meant to be called by orders
    public func deleteProduct(for id: UUID) throws -> () {
        throw ProductsError.invalidProduct
    }

    public func updateProduct(for id: UUID, with data: ProductPatch,
                              from address: Address) throws -> Product
    {
        if let callback = callbacks[id] {
            callback(data)
        }

        return try getProduct(for: id, from: Address())     // This is just a stub
    }

    // NOTE: Not meant to be called by orders
    public func addProductProperty(for id: UUID, with data: ProductPropertyAdditionPatch,
                                   from address: Address) throws -> Product
    {
        throw ProductsError.invalidProduct
    }

    // NOTE: Not meant to be called by orders
    public func deleteProductProperty(for id: UUID, with data: ProductPropertyDeletionPatch,
                                      from address: Address) throws -> Product
    {
        throw ProductsError.invalidProduct
    }

    // NOTE: Not meant to be called by orders
    public func createCollection(with data: ProductCollectionData) throws -> ProductCollection {
        throw ProductsError.invalidCollection
    }

    // NOTE: Not meant to be called by orders
    public func updateCollection(for id: UUID, with data: ProductCollectionPatch) throws -> ProductCollection {
        throw ProductsError.invalidCollection
    }

    // NOTE: Not meant to be called by orders
    public func deleteCollection(for id: UUID) throws -> () {
        throw ProductsError.invalidCollection
    }

    // NOTE: Not meant to be called by orders
    public func addProduct(to id: UUID, using data: ProductCollectionItemPatch) throws -> ProductCollection {
        throw ProductsError.invalidCollection
    }

    // NOTE: Not meant to be called by orders
    public func removeProduct(from id: UUID, using data: ProductCollectionItemPatch) throws -> ProductCollection {
        throw ProductsError.invalidCollection
    }
}
