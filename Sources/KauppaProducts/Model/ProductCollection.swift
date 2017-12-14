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
    public let updatedAt: Date
    /// User-supplied data for this collection.
    public let data: ProductCollectionData
}

/// A collection of products.
public struct ProductCollectionData: Mappable {
    /// Name of this collection
    public let name: String
    /// Description for this collection.
    public let description: String
    /// Products added to this collection.
    public let products = ArraySet<UUID>()
}
