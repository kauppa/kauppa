import Foundation
import XCTest

import KauppaProductsClient
import KauppaProductsModel

public class TestProductsService: ProductsServiceCallable {
    var products = [UUID: Product]()

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

    // NOTE: Not meant to be called by cart
    public func deleteProduct(id: UUID) throws -> () {
        throw ProductsError.invalidProduct
    }

    // NOTE: Not meant to be called by cart
    public func updateProduct(id: UUID, data: ProductPatch) throws -> Product {
        throw ProductsError.invalidProduct
    }

    // NOTE: Not meant to be called by cart
    public func addProductProperty(id: UUID, data: ProductPropertyAdditionPatch) throws -> Product {
        throw ProductsError.invalidProduct
    }

    // NOTE: Not meant to be called by cart
    public func deleteProductProperty(id: UUID, data: ProductPropertyDeletionPatch) throws -> Product {
        throw ProductsError.invalidProduct
    }
}
