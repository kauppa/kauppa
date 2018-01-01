import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaProductsClient
import KauppaProductsModel
import KauppaProductsRepository
import KauppaTaxClient

/// Products service
public class ProductsService {
    let repository: ProductsRepository
    let taxService: TaxServiceCallable

    /// Initialize this service with a repository and tax service.
    ///
    /// - Parameters:
    ///   - with: `ProductsRepository`
    ///   - taxService: Anything that implements `TaxServiceCallable`
    public init(with repository: ProductsRepository, taxService: TaxServiceCallable) {
        self.repository = repository
        self.taxService = taxService
    }
}

// NOTE: See the actual protocol in `KauppaProductsClient` for exact usage.
extension ProductsService: ProductsServiceCallable {
    public func getCategories() throws -> [Category] {
        return try repository.getCategories()
    }

    public func getAttributes() throws -> [Attribute] {
        return try repository.getAttributes()
    }

    public func createProduct(with data: Product, from address: Address?) throws -> Product
    {
        let factory = ProductsFactory(for: data, with: repository, from: address)
        let product = try factory.createProduct(using: taxService)
        return try getProduct(for: product.id!, from: address)
    }

    public func getProduct(for id: UUID, from address: Address?) throws -> Product {
        var product = try repository.getProduct(for: id)
        if !(product.taxInclusive ?? false) {
            if let address = address {
                let taxRate = try taxService.getTaxRate(for: address)
                product.setTax(using: taxRate)
            }
        }

        return product
    }

    // FIXME: Pagination
    public func getProducts() throws -> [Product] {
        return try repository.getProducts()
    }

    public func deleteProduct(for id: UUID) throws -> () {
        return try repository.deleteProduct(for: id)
    }

    public func updateProduct(for id: UUID, with data: ProductPatch,
                              from address: Address?) throws -> Product
    {
        let product = try repository.getProduct(for: id)
        let factory = ProductsFactory(for: product, with: repository, from: address)
        try factory.updateProduct(for: id, with: data, using: taxService)
        return try getProduct(for: id, from: address)
    }

    public func addProductProperty(for id: UUID, with data: ProductPropertyAdditionPatch,
                                   from address: Address?) throws -> Product
    {
        var productData = try repository.getProduct(for: id)

        if let image = data.image {
            if productData.images == nil {
                productData.images = ArraySet([image])
            } else {
                productData.images!.insert(image)
            }
        }

        let _ = try repository.updateProduct(with: productData)
        return try getProduct(for: id, from: address)
    }

    public func deleteProductProperty(for id: UUID, with data: ProductPropertyDeletionPatch,
                                      from address: Address?) throws -> Product
    {
        var productData = try repository.getProduct(for: id)

        if (data.removeOverview ?? false) {
            productData.overview = nil
        }

        if (data.removeTaxCategory ?? false) {
            productData.taxCategory = nil
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

        if let index = data.removeCategoryAt {
            if productData.categories != nil {
                productData.categories!.remove(at: index)
            }
        }

        if let index = data.removeTagAt {
            if productData.tags != nil {
                productData.tags!.remove(at: index)
            }
        }

        if let index = data.removeImageAt {
            if productData.images != nil {
                productData.images!.remove(at: index)
            }
        }

        if (data.removeVariant ?? false) {
            if let parentId = productData.variantId {
                var parentData = try repository.getProduct(for: parentId)
                if parentData.variants != nil {
                    parentData.variants!.remove(id)
                }

                let _ = try repository.updateProduct(with: parentData)
                productData.variantId = nil
            }
        }

        let _ = try repository.updateProduct(with: productData)
        return try getProduct(for: id, from: address)
    }

    public func createCollection(with data: ProductCollectionData) throws -> ProductCollection {
        for productId in data.products {
            let _ = try repository.getProduct(for: productId)
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
                let _ = try repository.getProduct(for: productId)
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
