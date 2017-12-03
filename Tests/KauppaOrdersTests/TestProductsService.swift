import Foundation
import XCTest

import KauppaProductsClient
import KauppaProductsModel

public typealias Callback = (ProductPatch) -> Void

public class TestProductsService: ProductsServiceCallable {
    var products = [UUID: Product]()
    public var callbacks = [UUID: Callback]()

    public func createProduct(data: ProductData) -> Product? {
        let id = UUID()
        let date = Date()
        products[id] = Product(id: id, createdOn: date, updatedAt: date, data: data)
        return products[id]
    }

    public func getProduct(id: UUID) -> Product? {
        return products[id]
    }

    public func deleteProduct(id: UUID) -> Bool {
        return products.removeValue(forKey: id) != nil
    }

    public func updateProduct(id: UUID, data: ProductPatch) -> Product? {
        if let callback = callbacks[id] {
            callback(data)
        }

        return products[id]
    }
}
