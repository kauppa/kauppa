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

    public func createProduct(data: ProductData) -> Product? {
        let id = UUID()
        let date = Date()
        let product = Product(id: id, createdOn: date,
                              updatedAt: date, data: data)
        self.store.createNewProduct(productData: product)
        products[id] = product
        return product
    }

    public func deleteProduct(id: UUID) -> Bool {
        products.removeValue(forKey: id)
        return store.deleteProduct(id: id)
    }

    public func getProductData(id: UUID) -> ProductData? {
        guard let product = getProduct(id: id) else {
            return nil
        }

        return product.data
    }

    public func updateProductData(id: UUID, data: ProductData) -> Product? {
        guard var product = getProduct(id: id) else {
            return nil
        }

        let date = Date()
        product.updatedAt = date
        product.data = data
        products[id] = product
        store.updateProduct(productData: product)
        return product
    }

    public func getProduct(id: UUID) -> Product? {
        guard let product = products[id] else {
            let result = store.getProduct(id: id)
            if let product = result {
                products[id] = product
            }

            return result
        }

        return product
    }
}
