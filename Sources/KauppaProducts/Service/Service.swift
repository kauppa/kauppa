import KauppaProductsModel
import KauppaProductsRepository

public class ProductsService {
    let repository: ProductsRepository

    public init(withRepository repository: ProductsRepository) {
        self.repository = repository
    }

    func createProduct(data: ProductData) -> Product? {
        var data = data

        if let variantId = data.variantId {
            if repository.getProduct(id: variantId) == nil {
                data.variantId = nil
            }
        }

        let productData = self.repository.createProduct(data: data)
        return productData
    }
}
