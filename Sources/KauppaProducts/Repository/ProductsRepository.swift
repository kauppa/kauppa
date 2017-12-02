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
        self.store.createNewProduct(id: id, product: product)
        products[id] = product
        return product
    }

    public func deleteProduct(id: UUID) -> Product? {
        return nil
    }

    public func updateProduct(id: UUID, data: ProductPatch) -> Product? {
        return nil
    }

    public func getProduct(id: UUID) -> Product? {
        guard let product = products[id] else {
            return store.getProduct(id: id)
        }

        return product
    }

    // TODO: Fix API
    func updateProductForId(id: UUID, product: Product) {
        products[id] = product
    }

    func removeProductIfExists(id: UUID) -> Product? {
        if let product = products[id] {
            products.removeValue(forKey: id)
            return product
        } else {
            return nil
        }
    }
}
