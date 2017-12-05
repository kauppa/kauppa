import Foundation
import XCTest

import KauppaProductsClient
import KauppaProductsModel

public typealias Callback = (ProductPatch) -> Void

public class TestProductsService: ProductsServiceCallable {
    var products = [UUID: Product]()
    public var callbacks = [UUID: Callback]()

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

    public func deleteProduct(id: UUID) throws -> () {
        if products.removeValue(forKey: id) != nil {
            return ()
        } else {
            throw ProductsError.invalidProduct
        }
    }

    public func updateProduct(id: UUID, data: ProductPatch) throws -> Product {
        if let callback = callbacks[id] {
            callback(data)
        }

        return try getProduct(id: id)   // This is just a stub
    }
}
