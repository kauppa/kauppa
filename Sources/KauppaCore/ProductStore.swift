import Foundation
import KauppaCore

protocol ProductStore {
    func createProduct(data: ProductData,
                       callback: @escaping (ObjectCreationData?) -> Void)
}

extension MemoryStore {
    func createProduct(data: ProductData,
                       callback: @escaping (ObjectCreationData?) -> Void)
    {
        let id = UUID()
        let date = Date()
        let creationData = ObjectCreationData(id: id,
                                              createdOn: date,
                                              updatedAt: date)
        products[id] = Product(creationData: creationData, productData: data)
        callback(creationData)
    }
}
