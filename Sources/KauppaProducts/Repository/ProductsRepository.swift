import Foundation 

import KauppaProductsModel

public class ProductsRepository {
    var products = [UUID: Product]()

    public func createProduct(data: ProductData) -> Product? {
        let product = Product(id: UUID(), createdOn: Date(), updatedAt: Date(), data: data)

        return product
    }

    public func deleteProduct(id: UUID) -> Product? {
        return nil
    }

    public func updateProduct(id: UUID, data: ProductPatch) -> Product? {
        return nil
    }

    public func getProduct(id: UUID) -> Product? {
        return nil
    }

    // TODO: Fix API
    func createNewProductWithId(id: UUID, product: Product) {
        products[id] = product
    }

    // TODO: Fix API
    func getProductForId(id: UUID) -> Product? {
        return products[id]
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