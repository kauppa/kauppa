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
        data.variants = []
        var variant: Product? = nil

        if let variantId = data.variantId {
            do {
                variant = try repository.getProduct(id: variantId)
            } catch {   // FIXME: check the error kind
                data.variantId = nil
            }
        }

        let productData = try repository.createProduct(data: data)
        if let variant = variant {
            var variantData = variant.data
            variantData.variants.insert(productData.id)
            // FIXME: Make sure that the data of variants is reflected
            let _ = try? repository.updateProductData(id: variant.id, data: variantData)
        }

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

        /// NOTE: No support for `variants` directly

        if let variantId = data.variantId {
            if variantId != id {
                var variant = try repository.getProduct(id: variantId)
                // Check if it's a child - if so, use its variantId instead.
                if let parentId = variant.data.variantId {
                    variant = try repository.getProduct(id: parentId)
                }

                productData.variantId = variant.id
                var variantData = variant.data
                if !variantData.variants.contains(id) {
                    variantData.variants.insert(id)
                    let _ = try repository.updateProductData(id: variant.id, data: variantData)
                }
            }
        }

        return try repository.updateProductData(id: id, data: productData)
    }
}
