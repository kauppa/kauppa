import Foundation
import XCTest

import KauppaCore
import KauppaAccountsModel
import KauppaProductsClient
import KauppaProductsModel

public class TestProductsService: ProductsServiceCallable {
    var products = [UUID: Product]()

    public func createProduct(with data: Product, from address: Address?) throws -> Product {
        products[data.id!] = data
        return data
    }

    public func getProduct(for id: UUID, from address: Address?) throws -> Product {
        guard let product = products[id] else {
            throw ServiceError.invalidProductId
        }

        return product
    }

    public func getAttributes() throws -> [Attribute] {
        return []
    }

    public func getCategories() throws -> [Category] {
        return []
    }

    public func getProducts() throws -> [Product] {
        return []
    }

    // NOTE: Not meant to be called by cart
    public func deleteProduct(for id: UUID) throws -> () {
        throw ServiceError.invalidProductId
    }

    // NOTE: Not meant to be called by cart
    public func updateProduct(for id: UUID, with data: ProductPatch,
                              from address: Address?) throws -> Product
    {
        throw ServiceError.invalidProductId
    }

    // NOTE: Not meant to be called by cart
    public func addProductProperty(for id: UUID, with data: ProductPropertyAdditionPatch,
                                   from address: Address?) throws -> Product
    {
        throw ServiceError.invalidProductId
    }

    // NOTE: Not meant to be called by cart
    public func deleteProductProperty(for id: UUID, with data: ProductPropertyDeletionPatch,
                                      from address: Address?) throws -> Product
    {
        throw ServiceError.invalidProductId
    }

    // NOTE: Not meant to be called by cart
    public func createCollection(with data: ProductCollectionData) throws -> ProductCollection {
        throw ServiceError.invalidCollectionId
    }

    // NOTE: Not meant to be called by cart
    public func updateCollection(for id: UUID, with data: ProductCollectionPatch) throws -> ProductCollection {
        throw ServiceError.invalidCollectionId
    }

    // NOTE: Not meant to be called by cart
    public func deleteCollection(for id: UUID) throws -> () {
        throw ServiceError.invalidCollectionId
    }

    // NOTE: Not meant to be called by cart
    public func addProduct(to id: UUID, using data: ProductCollectionItemPatch) throws -> ProductCollection {
        throw ServiceError.invalidCollectionId
    }

    // NOTE: Not meant to be called by cart
    public func removeProduct(from id: UUID, using data: ProductCollectionItemPatch) throws -> ProductCollection {
        throw ServiceError.invalidCollectionId
    }
}
