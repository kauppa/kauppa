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

    public init(with repository: ProductsRepository, taxService: TaxServiceCallable) {
        self.repository = repository
        self.taxService = taxService
    }
}

// NOTE: See the actual protocol in `KauppaProductsClient` for exact usage.
extension ProductsService: ProductsServiceCallable {
    public func createProduct(with data: ProductData,
                              from address: Address) throws -> Product
    {
        var data = data
        data.variants = []  // ensure that variants can't be "set" manually
        try data.validate()
        var variant: Product? = nil

        // Check the variant data (if provided)
        if let variantId = data.variantId {
            do {
                variant = try repository.getProduct(for: variantId)
                // also check whether this is another variant (if so, use its parent)
                if let parentId = variant!.data.variantId {
                    variant = try repository.getProduct(for: parentId)
                    data.variantId = variant!.id
                }
            } catch {   // FIXME: check the error kind
                data.variantId = nil
            }
        }

        let taxRate = try taxService.getTaxRate(for: address)
        data.stripTax(using: taxRate)

        let product = Product(data: data)
        let _ = try repository.createProduct(with: product)
        if let variant = variant {
            var variantData = variant.data
            variantData.variants.insert(product.id)
            let _ = try repository.updateProduct(for: variant.id, with: variantData)
        }

        return try getProduct(for: product.id, from: address)
    }

    public func getProduct(for id: UUID, from address: Address) throws -> Product {
        var product = try repository.getProduct(for: id)
        let taxRate = try taxService.getTaxRate(for: address)
        product.data.setTax(using: taxRate)
        return product
    }

    public func deleteProduct(for id: UUID) throws -> () {
        return try repository.deleteProduct(for: id)
    }

    public func updateProduct(for id: UUID, with data: ProductPatch,
                              from address: Address) throws -> Product
    {
        var productData = try repository.getProductData(for: id)

        if let title = data.title {
            productData.title = title
        }

        if let subtitle = data.subtitle {
            productData.subtitle = subtitle
        }

        if let description = data.description {
            productData.description = description
        }

        if let dimensions = data.dimensions {
            if productData.dimensions == nil {
                productData.dimensions = dimensions
            } else {
                if let length = dimensions.length {
                    productData.dimensions!.length = length
                }
                if let width = dimensions.width {
                    productData.dimensions!.width = width
                }
                if let height = dimensions.height {
                    productData.dimensions!.height = height
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

        if data.taxInclusive ?? false {
            productData.taxInclusive = true
            let taxRate = try taxService.getTaxRate(for: address)
            productData.stripTax(using: taxRate)
        }

        /// NOTE: No support for `variants` directly

        if let variantId = data.variantId {
            if variantId != id {
                var variant = try repository.getProduct(for: variantId)
                // Check if it's a child - if so, use its variantId instead.
                if let parentId = variant.data.variantId {
                    variant = try repository.getProduct(for: parentId)
                }

                productData.variantId = variant.id
                var variantData = variant.data
                if !variantData.variants.contains(id) {
                    variantData.variants.insert(id)
                    let _ = try repository.updateProduct(for: variant.id, with: variantData)
                }
            }
        }

        let _ = try repository.updateProduct(for: id, with: productData)
        return try getProduct(for: id, from: address)
    }

    public func addProductProperty(for id: UUID, with data: ProductPropertyAdditionPatch,
                                   from address: Address) throws -> Product
    {
        var productData = try repository.getProductData(for: id)

        if let image = data.image {
            productData.images.insert(image)
        }

        let _ = try repository.updateProduct(for: id, with: productData)
        return try getProduct(for: id, from: address)
    }

    public func deleteProductProperty(for id: UUID, with data: ProductPropertyDeletionPatch,
                                      from address: Address) throws -> Product
    {
        var productData = try repository.getProductData(for: id)

        if (data.removeCategory ?? false) {
            productData.category = nil
        }

        if (data.removeColor ?? false) {
            productData.color = nil
        }

        if (data.removeDimensions ?? false) {
            productData.dimensions =  nil
        }

        if (data.removeWeight ?? false) {
            productData.weight = nil
        }

        if let index = data.removeImageAt {
            productData.images.remove(at: index)
        }

        if (data.removeVariant ?? false) {
            if let parentId = productData.variantId {
                var parentData = try repository.getProductData(for: parentId)
                parentData.variants.remove(id)
                let _ = try repository.updateProduct(for: parentId, with: parentData)
                productData.variantId = nil
            }
        }

        let _ = try repository.updateProduct(for: id, with: productData)
        return try getProduct(for: id, from: address)
    }

    public func createCollection(with data: ProductCollectionData) throws -> ProductCollection {
        for productId in data.products {
            let _ = try repository.getProductData(for: productId)
        }

        try data.validate()
        return try repository.createCollection(with: data)
    }

    public func updateCollection(for id: UUID, with data: ProductCollectionPatch) throws
                                -> ProductCollection
    {
        var collectionData = try repository.getCollectionData(for: id)

        if let name = data.name {
            collectionData.name = name
        }

        if let description = data.description {
            collectionData.description = description
        }

        try collectionData.validate()
        if let products = data.products {
            for productId in products {
                let _ = try repository.getProductData(for: productId)
            }

            collectionData.products = products
        }

        return try repository.updateCollection(for: id, with: collectionData)
    }

    public func deleteCollection(for id: UUID) throws -> () {
        return try repository.deleteCollection(for: id)
    }

    public func addProduct(to id: UUID, using data: ProductCollectionItemPatch) throws
                          -> ProductCollection
    {
        var collectionData = try repository.getCollectionData(for: id)
        var products = data.products ?? []
        if let productId = data.product {
            products.append(productId)
        }

        for productId in products {
            let _ = try repository.getProduct(for: productId)
            collectionData.products.insert(productId)
        }

        return try repository.updateCollection(for: id, with: collectionData)
    }

    public func removeProduct(from id: UUID, using data: ProductCollectionItemPatch) throws
                             -> ProductCollection
    {
        var collectionData = try repository.getCollectionData(for: id)
        var products = data.products ?? []
        if let productId = data.product {
            products.append(productId)
        }

        for productId in products {
            // If product exists in our collection, we remove it.
            collectionData.products.remove(productId)
        }

        return try repository.updateCollection(for: id, with: collectionData)
    }
}
