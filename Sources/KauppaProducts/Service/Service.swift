import Foundation

import KauppaProductsRepository

public class ProductsService {
    let repository: ProductsRepository

    public init(withRepository repository: ProductsRepository) {
        self.repository = repository
    }

    func createProduct(data: ProductData) -> Product? {
        let id = UUID()
        let date = Date()
        var data = data

        if let variantId = data.variantId {
            if self.repository.getProductForId(id: variantId) == nil {
                data.variantId = nil
            }
        }

        let productData = self.repository.createNewProduct(data: data)
        return productData
    }
}
