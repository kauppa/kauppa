import Foundation

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

    func deleteProduct(id: UUID) -> Bool {
        return repository.deleteProduct(id: id)
    }

    func updateProduct(id: UUID, data: ProductPatch) -> Product? {
        guard var productData = repository.getProductData(id: id) else {
            return nil
        }

        if let title = data.title {
            productData.title = title
        }

        if let subtitle = data.subtitle {
            productData.subtitle = subtitle
        }

        if let description = data.description {
            productData.description = description
        }

        if let size = data.size {
            if productData.size == nil {
                productData.size = size
            } else {
                if let length = size.length {
                    productData.size!.length = length
                }
                if let width = size.width {
                    productData.size!.width = width
                }
                if let height = size.height {
                    productData.size!.height = height
                }
            }
        }

        if let color = data.color {
            productData.color = color
        }

        if let weight = data.weight {
            productData.weight = weight
        }

        if let inventory = data.inventory {
            productData.inventory = inventory
        }

        if let image = data.image {
            productData.images.append(image)
        }

        if let price = data.price {
            productData.price = price
        }

        if let category = data.category {
            productData.category = category
        }

        if let variantId = data.variantId {
            if variantId != id && repository.getProduct(id: variantId) != nil {
                productData.variantId = variantId
            }
        }

        return repository.updateProductData(id: id, data: productData)
    }
}
