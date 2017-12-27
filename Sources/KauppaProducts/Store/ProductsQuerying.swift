import Foundation

import KauppaCore
import KauppaProductsModel

/// Methods that simply reference the store for information.
public protocol ProductsQuerying: Querying {
    /// Get the product data corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product.
    /// - Returns: `Product` (if it exists).
    /// - Throws: `ServiceError` on failure.
    func getProduct(for id: UUID) throws -> Product

    /// Get the attribute data for the given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the attribute.
    /// - Returns: `Attribute` (if it exists).
    /// - Throws: `ServiceError` on failure.
    func getAttribute(for id: UUID) throws -> Attribute

    /// Get the collection data corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product collection.
    /// - Returns: `ProductCollection` (if it exists).
    /// - Throws: `ServiceError` on failure.
    func getCollection(for id: UUID) throws -> ProductCollection
}
