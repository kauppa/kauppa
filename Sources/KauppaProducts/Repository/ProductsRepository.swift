import Foundation

import KauppaProductsModel
import KauppaProductsStore

public class ProductsRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var products = [UUID: Product]()
    var collections = [UUID: ProductCollection]()

    // Categories can't go beyond say, 100 - so, we're safe here
    var categories = Set<String>()
    // Tags can't go beyond say, 1000 - so, we're safe (again).
    var tags = Set<String>()

    let store: ProductsStorable

    /// Initialize this repository with a store.
    public init(withStore store: ProductsStorable) {
        self.store = store
    }

    /// Create product from the given product data.
    public func createProduct(data: Product) throws -> Product {
        try self.store.createNewProduct(productData: data)
        products[data.id] = data
        updateCategoriesAndTags(using: data)
        return data
    }

    /// Delete the product corresponding to an ID.
    public func deleteProduct(id: UUID) throws -> () {
        products.removeValue(forKey: id)
        return try store.deleteProduct(id: id)
    }

    /// Get the product data corresponding to an ID.
    public func getProductData(id: UUID) throws -> ProductData {
        let product = try getProduct(id: id)
        return product.data
    }

    /// Update the product data for a given product ID.
    public func updateProductData(id: UUID, data: ProductData) throws -> Product {
        var product = try getProduct(id: id)
        product.updatedAt = Date()
        product.data = data
        products[id] = product
        try store.updateProduct(productData: product)
        return product
    }

    /// Fetch the whole product (from repository, if it's available, or store, if not).
    public func getProduct(id: UUID) throws -> Product {
        guard let product = products[id] else {
            let product = try store.getProduct(id: id)
            products[id] = product
            updateCategoriesAndTags(using: product)
            return product
        }

        updateCategoriesAndTags(using: product)
        return product
    }

    /// Create a product collection with data from the service.
    public func createCollection(with data: ProductCollectionData) throws -> ProductCollection {
        let id = UUID()
        let date = Date()
        let collection = ProductCollection(id: id, createdOn: date,
                                           updatedAt: date, data: data)
        try self.store.createNewCollection(data: collection)
        collections[id] = collection
        return collection
    }

    /// Fetch the entire collection (from repository, if it's available, or store, if not)
    public func getCollection(id: UUID) throws -> ProductCollection {
        guard let collection = collections[id] else {
            let collection = try store.getCollection(id: id)
            collections[id] = collection
            return collection
        }

        return collection
    }

    /// Get the product data from the collection.
    public func getCollectionData(id: UUID) throws -> ProductCollectionData {
        let collection = try getCollection(id: id)
        return collection.data
    }

    /// Update a collection with data from the service.
    public func updateCollectionData(id: UUID, data: ProductCollectionData) throws -> ProductCollection {
        var collection = try getCollection(id: id)
        let date = Date()
        collection.updatedAt = date
        collection.data = data
        collections[id] = collection
        try store.updateCollection(data: collection)
        return collection
    }

    /// Delete the collection corresponding to an ID.
    public func deleteCollection(id: UUID) throws -> () {
        collections.removeValue(forKey: id)
        return try store.deleteCollection(id: id)
    }

    private func updateCategoriesAndTags(using product: Product) {
        if let category = product.data.category {
            categories.insert(category)
        }

        for tag in product.data.tags {
            tags.insert(tag)
        }
    }
}
