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

    var categories = [UUID: Category]()
    // Categories can't go beyond say, 100 - so, we're safe here.
    var categoryNames = [String: UUID]()
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
    /// - Throws: `ServiceError` on failure.
    public func createProduct(with product: Product) throws -> Product {
        try self.store.createNewProduct(with: product)
        products[product.id] = product

        // Update in-memory tags
        tags.formUnion(product.data.tags)

        return product
    }

    /// Delete the product corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product.
    /// - Throws: `ServiceError` on failure.
    public func deleteProduct(for id: UUID) throws -> () {
        products.removeValue(forKey: id)
        return try store.deleteProduct(for: id)
    }

    public func getProducts() throws -> [Product] {
        return Array(products.values)
    }

    /// Get the product data corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product.
    /// - Returns: `ProductData` for that product (if it exists).
    /// - Throws: `ServiceError` on failure.
    public func getProductData(for id: UUID) throws -> ProductData {
        let product = try getProduct(for: id)
        return product.data
    }

    /// Update the product data for a given product ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product.
    /// - Returns: Updated `Product` object (if it exists).
    /// - Throws: `ServiceError` on failure.
    public func updateProduct(for id: UUID, with data: ProductData) throws -> Product {
        var product = try getProduct(for: id)
        product.updatedAt = Date()
        product.data = data
        products[id] = product
        try store.updateProduct(with: product)

        // Update in-memory tags
        tags.formUnion(product.data.tags)

        return product
    }

    /// Fetch the whole product (from repository, if it's available, or store, if not).
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product.
    /// - Returns: `Product` object (if it exists).
    /// - Throws: `ServiceError` on failure.
    public func getProduct(for id: UUID) throws -> Product {
        var product = products[id]
        if product == nil {
            product = try store.getProduct(for: id)
            products[id] = product
        }

        return product!
    }

    public func createCategory(with data: Category) throws -> Category {
        var category = data
        let id = UUID()
        let name = category.name!.lowercased()
        category.id = id
        category.name = name

        categories[id] = category
        categoryNames[name] = id

        try store.createCategory(with: category)
        return category
    }

    public func getCategory(for id: UUID) throws -> Category {
        guard let category = categories[id] else {
            let category = try store.getCategory(for: id)
            categoryNames[category.name!] = id
            categories[id] = category
            return category
        }

        return category
    }

    public func getCategory(for name: String) throws -> Category {
        guard let id = categoryNames[name] else {
            let category = try store.getCategory(for: name)
            categoryNames[category.name!] = category.id!
            categories[category.id!] = category
            return category
        }

        return try getCategory(for: id)
    }

    /// Create an attribute with the given name and type.
    ///
    /// - Parameters:
    ///   - with: The name of the attribute.
    ///   - and: The `BaseType` of the attribute.
    ///   - variants: (Optional) list of variants (if it's an enum).
    /// - Returns: `Attribute` with the given data.
    /// - Throws: `ServiceError` on failure.
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
    /// - Throws: `ServiceError` on failure.
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
    /// - Throws: `ServiceError` on failure.
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
    /// - Throws: `ServiceError` on failure.
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
    /// - Throws: `ServiceError` on failure.
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
    /// - Throws: `ServiceError` on failure.
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
    /// - Throws: `ServiceError` on failure.
    public func deleteCollection(for id: UUID) throws -> () {
        collections.removeValue(forKey: id)
        return try store.deleteCollection(for: id)
    }
}
