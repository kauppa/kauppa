import Foundation

protocol ProductStore {
    func createProduct(data: ProductData) -> Product?
    func deleteProduct(id: UUID) -> Product?
}

extension MemoryStore: ProductStore {
    func createProduct(data: ProductData) -> Product? {
        let id = UUID()
        let date = Date()
        let productData = Product(id: id,
                                  createdOn: date,
                                  updatedAt: date,
                                  data: data)
        products[id] = productData
        return productData
    }

    func deleteProduct(id: UUID) -> Product? {
        if let product = products[id] {
            products.removeValue(forKey: id)
            return product
        } else {
            return nil
        }
    }
}
