import Foundation

import KauppaProductsClient
import KauppaProductsModel
import KauppaProductsRepository

/// Products service
public class ProductsService: ProductsServiceCallable {
    let repository: ProductsRepository

    public init(withRepository repository: ProductsRepository) {
        self.repository = repository
    }

    public func createProduct(data: ProductData) throws -> Product {
        var data = data

        if let variantId = data.variantId {
            do {
                let _ = try repository.getProduct(id: variantId)
            } catch {
                data.variantId = nil
            }
        }

        let productData = try self.repository.createProduct(data: data)
        return productData
    }

    public func getProduct(id: UUID) throws -> Product {
        return try repository.getProduct(id: id)
    }

    public func deleteProduct(id: UUID) throws -> () {
        return try repository.deleteProduct(id: id)
    }

    public func updateProduct(id: UUID, data: ProductPatch) throws -> Product {
        var productData = try repository.getProductData(id: id)

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

        if let images = data.images {
            productData.images = images
        }

        if let price = data.price {
            productData.price = price
        }

        if let category = data.category {
            productData.category = category
        }

        if let variantId = data.variantId {
            if variantId != id {
                let _ = try repository.getProduct(id: variantId)
                productData.variantId = variantId
            }
        }

        return try repository.updateProductData(id: id, data: productData)
    }
}
