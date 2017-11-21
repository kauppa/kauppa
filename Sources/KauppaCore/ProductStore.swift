import Foundation

protocol ProductStore {
    func createProduct(data: ProductData,
                       callback: @escaping (Product?) -> Void)
    func deleteProduct(id: UUID,
                       callback: @escaping (Product?) -> Void)
}

extension MemoryStore: ProductStore {
    func createProduct(data: ProductData,
                       callback: @escaping (Product?) -> Void)
    {
        let id = UUID()
        let date = Date()
        let productData = Product(id: id,
                                  createdOn: date,
                                  updatedAt: date,
                                  data: data)
        products[id] = productData
        callback(productData)
    }

    func deleteProduct(id: UUID, callback: @escaping (Product?) -> Void) {
        if let product = products[id] {
            products.removeValue(forKey: id)
            callback(product)
        } else {
            callback(nil)
        }
    }
}
