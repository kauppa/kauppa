import Foundation

import KauppaCore

/// Represents the structure of the product collection in
/// repository and store.
public struct ProductCollection: Mappable {
    /// Unique identifier for this collection.
    public let id = UUID()
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// User-supplied data for this collection.
    public var data: ProductCollectionData

    /// Initialize an instance with the collection data.
    ///
    /// - Parameters:
    ///   - with: `ProductCollectionData`
    public init(with data: ProductCollectionData) {
        let date = Date()
        self.createdOn = date
        self.updatedAt = date
        self.data = data
    }
}

/// Represents a collection of products.
public struct ProductCollectionData: Mappable {
    /// Name of this collection
    public var name: String
    /// Description for this collection.
    public var description: String
    /// Products added to this collection.
    public var products: Set<UUID>

    /// Initialize an instance with name, description and list of products (for tests).
    init(name: String, description: String, products: Set<UUID>) {
        self.name = name
        self.description = description
        self.products = products
    }

    /// Validate this instance for possible errors. Currently, it checks the name
    /// and description.
    ///
    /// - Throws: `ProductsError` for invalid data.
    public func validate() throws {
        if name.isEmpty {
            throw ProductsError.invalidCollectionName
        }

        if description.isEmpty {
            throw ProductsError.invalidCollectionDescription
        }
    }
}
