import Foundation

import KauppaCore
import KauppaProductsModel
import KauppaProductsStore

public class ProductsRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var products = [UUID: Product]()
    var collections = [UUID: ProductCollection]()
    var attributes = [UUID: Attribute]()

    // Categories can't go beyond say, 100 - so, we're safe here
    var categories = Set<String>()
    // Tags can't go beyond say, 1000 - so, we're safe (again).
    var tags = Set<String>()

    let store: ProductsStorable

    /// Initialize this repository with a store.
    ///
    /// - Parameters:
    ///   - with: Anything that implements `ProductsStorable`
    public init(with store: ProductsStorable) {
        self.store = store
    }

    /// Create product from the given product data.
    ///
    /// - Parameters:
    ///   - with: `ProductData`
    /// - Returns: `Product` initialized with the given data.
    /// - Throws: `ProductsError` on failure.
    public func createProduct(with data: Product) throws -> Product {
        try self.store.createNewProduct(with: data)
        products[data.id] = data
        updateCategoriesAndTags(using: data)
        return data
    }

    /// Delete the product corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product.
    /// - Throws: `ProductsError` on failure.
    public func deleteProduct(for id: UUID) throws -> () {
        products.removeValue(forKey: id)
        return try store.deleteProduct(for: id)
    }

    /// Get the product data corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product.
    /// - Returns: `ProductData` for that product (if it exists).
    /// - Throws: `ProductsError` on failure.
    public func getProductData(for id: UUID) throws -> ProductData {
        let product = try getProduct(for: id)
        return product.data
    }

    /// Update the product data for a given product ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product.
    /// - Returns: Updated `Product` object (if it exists).
    /// - Throws: `ProductsError` on failure.
    public func updateProduct(for id: UUID, with data: ProductData) throws -> Product {
        var product = try getProduct(for: id)
        product.updatedAt = Date()
        product.data = data
        products[id] = product
        try store.updateProduct(with: product)
        return product
    }

    /// Fetch the whole product (from repository, if it's available, or store, if not).
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product.
    /// - Returns: `Product` object (if it exists).
    /// - Throws: `ProductsError` on failure.
    public func getProduct(for id: UUID) throws -> Product {
        guard let product = products[id] else {
            let product = try store.getProduct(for: id)
            products[id] = product
            updateCategoriesAndTags(using: product)
            return product
        }

        updateCategoriesAndTags(using: product)
        return product
    }

    /// Create an attribute with the given name and type.
    ///
    /// - Parameters:
    ///   - with: The name of the attribute.
    ///   - and: The `BaseType` of the attribute.
    ///   - variants: (Optional) list of variants (if it's an enum).
    /// - Returns: `Attribute` with the given data.
    /// - Throws: `ProductsError` on failure.
    public func createAttribute(with name: String, and type: BaseType,
                                variants: ArraySet<String>? = nil) throws -> Attribute
    {
        var attribute = Attribute(with: name.lowercased(), and: type)
        if let variants = variants {
            attribute.variants = variants
        }

        attributes[attribute.id] = attribute
        try store.createAttribute(with: attribute)
        return attribute
    }

    /// Get the attribute for the given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the attribute.
    /// - Returns: `Attribute` (if it exists).
    /// - Throws: `ProductsError` on failure.
    public func getAttribute(for id: UUID) throws -> Attribute {
        guard let attribute = attributes[id] else {
            let attribute = try store.getAttribute(for: id)
            attributes[id] = attribute
            return attribute
        }

        return attribute
    }

    /// Create a product collection with data from the service.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product collection.
    /// - Returns: `ProductCollection`
    /// - Throws: `ProductsError` on failure.
    public func createCollection(with data: ProductCollectionData) throws
                                -> ProductCollection
    {
        let collection = ProductCollection(with: data)
        try self.store.createNewCollection(with: collection)
        collections[collection.id] = collection
        return collection
    }

    /// Fetch the entire collection (from repository, if it's available, or store, if not)
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product collection.
    /// - Returns: `ProductCollection` (if it exists).
    /// - Throws: `ProductsError` on failure.
    public func getCollection(for id: UUID) throws -> ProductCollection {
        guard let collection = collections[id] else {
            let collection = try store.getCollection(for: id)
            collections[id] = collection
            return collection
        }

        return collection
    }

    /// Get the product data from the collection.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product collection.
    /// - Returns: `ProductCollectionData` (if it exists).
    /// - Throws: `ProductsError` on failure.
    public func getCollectionData(for id: UUID) throws -> ProductCollectionData {
        let collection = try getCollection(for: id)
        return collection.data
    }

    /// Update a collection with data from the service.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product collection.
    ///   - with: `ProductCollectionData`
    /// - Returns: Updated `ProductCollection` (if it exists)
    /// - Throws: `ProductsError` on failure.
    public func updateCollection(for id: UUID, with data: ProductCollectionData) throws
                                -> ProductCollection
    {
        var collection = try getCollection(for: id)
        let date = Date()
        collection.updatedAt = date
        collection.data = data
        collections[id] = collection
        try store.updateCollection(with: collection)
        return collection
    }

    /// Delete the collection corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product collection.
    /// - Throws: `ProductsError` on failure.
    public func deleteCollection(for id: UUID) throws -> () {
        collections.removeValue(forKey: id)
        return try store.deleteCollection(for: id)
    }

    /// Update the in-memory tags and collections using the product data.
    private func updateCategoriesAndTags(using product: Product) {
        if let category = product.data.category {
            categories.insert(category)
        }

        for tag in product.data.tags {
            tags.insert(tag)
        }
    }
}
