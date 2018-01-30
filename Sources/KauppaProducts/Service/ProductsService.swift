import Foundation

import KauppaAccountsModel
import KauppaProductsClient
import KauppaProductsModel
import KauppaProductsRepository
import KauppaTaxClient

/// Products service
public class ProductsService {
    let repository: ProductsRepository
    let taxService: TaxServiceCallable

    public init(withRepository repository: ProductsRepository,
                taxService: TaxServiceCallable)
    {
        self.repository = repository
        self.taxService = taxService
    }
}

// NOTE: See the actual protocol in `KauppaProductsClient` for exact usage.
extension ProductsService: ProductsServiceCallable {
    public func createProduct(data: ProductData,
                              from address: Address) throws -> Product
    {
        var data = data
        data.variants = []  // ensure that variants can't be "set" manually
        try data.validate()
        var variant: Product? = nil

        // Check the variant data (if provided)
        if let variantId = data.variantId {
            do {
                variant = try repository.getProduct(id: variantId)
                // also check whether this is another variant (if so, use its parent)
                if let parentId = variant!.data.variantId {
                    variant = try repository.getProduct(id: parentId)
                    data.variantId = variant!.id
                }
            } catch {   // FIXME: check the error kind
                data.variantId = nil
            }
        }

        let taxRate = try taxService.getTaxRate(forAddress: address)
        data.stripTax(using: taxRate)

        var product = Product(data: data)
        try repository.createProduct(data: product)
        if let variant = variant {
            var variantData = variant.data
            variantData.variants.insert(product.id)
            let _ = try repository.updateProductData(id: variant.id, data: variantData)
        }

        return try getProduct(id: product.id, from: address)
    }

    public func getProduct(id: UUID, from address: Address) throws -> Product {
        var product = try repository.getProduct(id: id)
        let taxRate = try taxService.getTaxRate(forAddress: address)
        product.data.setTax(using: taxRate)
        return product
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

    public func addProductProperty(id: UUID, data: ProductPropertyAdditionPatch) throws -> Product {
        var productData = try repository.getProductData(id: id)

        if let image = data.image {
            productData.images.insert(image)
        }

        return try repository.updateProductData(id: id, data: productData)
    }

    public func deleteProductProperty(id: UUID, data: ProductPropertyDeletionPatch) throws -> Product {
        var productData = try repository.getProductData(id: id)

        if (data.removeCategory ?? false) {
            productData.category = nil
        }

        if (data.removeColor ?? false) {
            productData.color = nil
        }

        if (data.removeSize ?? false) {
            productData.size =  nil
        }

        if (data.removeWeight ?? false) {
            productData.weight = nil
        }

        if let index = data.removeImageAt {
            productData.images.remove(at: index)
        }

        if (data.removeVariant ?? false) {
            if let parentId = productData.variantId {
                var parentData = try repository.getProductData(id: parentId)
                parentData.variants.remove(id)
                let _ = try repository.updateProductData(id: parentId, data: parentData)
                productData.variantId = nil
            }
        }

        return try repository.updateProductData(id: id, data: productData)
    }

    public func createCollection(data: ProductCollectionData) throws -> ProductCollection {
        for productId in data.products {
            let _ = try repository.getProductData(id: productId)
        }

        try data.validate()
        return try repository.createCollection(with: data)
    }

    public func updateCollection(id: UUID, data: ProductCollectionPatch) throws -> ProductCollection {
        var collectionData = try repository.getCollectionData(id: id)

        if let name = data.name {
            collectionData.name = name
        }

        if let description = data.description {
            collectionData.description = description
        }

        try collectionData.validate()
        if let products = data.products {
            for productId in products {
                let _ = try repository.getProductData(id: productId)
            }

            collectionData.products = products
        }

        return try repository.updateCollectionData(id: id, data: collectionData)
    }

    public func deleteCollection(id: UUID) throws -> () {
        return try repository.deleteCollection(id: id)
    }

    public func addProduct(toCollection id: UUID, data: ProductCollectionItemPatch) throws -> ProductCollection {
        var collectionData = try repository.getCollectionData(id: id)
        var products = data.products ?? []
        if let productId = data.product {
            products.append(productId)
        }

        for productId in products {
            let _ = try repository.getProductData(id: productId)
            collectionData.products.insert(productId)
        }

        return try repository.updateCollectionData(id: id, data: collectionData)
    }

    public func removeProduct(fromCollection id: UUID, data: ProductCollectionItemPatch) throws -> ProductCollection {
        var collectionData = try repository.getCollectionData(id: id)
        var products = data.products ?? []
        if let productId = data.product {
            products.append(productId)
        }

        for productId in products {
            // If product exists in our collection, we remove it.
            collectionData.products.remove(productId)
        }

        return try repository.updateCollectionData(id: id, data: collectionData)
    }
}
