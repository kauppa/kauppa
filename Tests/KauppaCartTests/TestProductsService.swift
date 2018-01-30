import Foundation
import XCTest

import KauppaAccountsModel
import KauppaProductsClient
import KauppaProductsModel

public class TestProductsService: ProductsServiceCallable {
    var products = [UUID: Product]()

    public func createProduct(data: ProductData, from address: Address) throws -> Product {
        let product = Product(data: data)
        products[product.id] = product
        return product
    }

    public func getProduct(id: UUID, from address: Address) throws -> Product {
        guard let product = products[id] else {
            throw ProductsError.invalidProduct
        }

        return product
    }

    // NOTE: Not meant to be called by cart
    public func deleteProduct(id: UUID) throws -> () {
        throw ProductsError.invalidProduct
    }

    // NOTE: Not meant to be called by cart
    public func updateProduct(id: UUID, data: ProductPatch,
                              from address: Address) throws -> Product
    {
        throw ProductsError.invalidProduct
    }

    // NOTE: Not meant to be called by cart
    public func addProductProperty(id: UUID, data: ProductPropertyAdditionPatch,
                                   from address: Address) throws -> Product
    {
        throw ProductsError.invalidProduct
    }

    // NOTE: Not meant to be called by cart
    public func deleteProductProperty(id: UUID, data: ProductPropertyDeletionPatch,
                                      from address: Address) throws -> Product
    {
        throw ProductsError.invalidProduct
    }

    // NOTE: Not meant to be called by cart
    public func createCollection(data: ProductCollectionData) throws -> ProductCollection {
        throw ProductsError.invalidCollection
    }

    // NOTE: Not meant to be called by cart
    public func updateCollection(id: UUID, data: ProductCollectionPatch) throws -> ProductCollection {
        throw ProductsError.invalidCollection
    }

    // NOTE: Not meant to be called by cart
    public func deleteCollection(id: UUID) throws -> () {
        throw ProductsError.invalidCollection
    }

    // NOTE: Not meant to be called by cart
    public func addProduct(toCollection id: UUID, data: ProductCollectionItemPatch) throws -> ProductCollection {
        throw ProductsError.invalidCollection
    }

    // NOTE: Not meant to be called by cart
    public func removeProduct(fromCollection id: UUID, data: ProductCollectionItemPatch) throws -> ProductCollection {
        throw ProductsError.invalidCollection
    }
}
