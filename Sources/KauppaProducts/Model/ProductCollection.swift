import Foundation

import KauppaCore

/// Represents the structure of the product collection in
/// repository and store.
public struct ProductCollection: Mappable {
    /// Unique identifier for this collection.
    public let id: UUID
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// User-supplied data for this collection.
    public var data: ProductCollectionData

    public init(id: UUID, createdOn: Date, updatedAt: Date, data: ProductCollectionData) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = updatedAt
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
    public var products: ArraySet<UUID>

    public init(name: String, description: String, products: ArraySet<UUID>) {
        self.name = name
        self.description = description
        self.products = products
    }
}
