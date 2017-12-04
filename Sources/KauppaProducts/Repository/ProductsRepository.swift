import Foundation

import KauppaProductsModel
import KauppaProductsStore

public class ProductsRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var products = [UUID: Product]()

    let store: ProductsStore

    public init(withStore store: ProductsStore) {
        self.store = store
    }

    public func createProduct(data: ProductData) throws -> Product {
        let id = UUID()
        let date = Date()
        let product = Product(id: id, createdOn: date,
                              updatedAt: date, data: data)
        try self.store.createNewProduct(productData: product)
        products[id] = product
        return product
    }

    public func deleteProduct(id: UUID) throws -> () {
        products.removeValue(forKey: id)
        return try store.deleteProduct(id: id)
    }

    public func getProductData(id: UUID) throws -> ProductData {
        let product = try getProduct(id: id)
        return product.data
    }

    public func updateProductData(id: UUID, data: ProductData) throws -> Product {
        var product = try getProduct(id: id)
        let date = Date()
        product.updatedAt = date
        product.data = data
        products[id] = product
        try store.updateProduct(productData: product)
        return product
    }

    public func getProduct(id: UUID) throws -> Product {
        guard let product = products[id] else {
            let product = try store.getProduct(id: id)
            products[id] = product
            return product
        }

        return product
    }
}
