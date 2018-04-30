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

    /// Get the category for the given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the category.
    /// - Returns: `Category` (if it exists).
    /// - Throws: `ServiceError` on failure.
    func getCategory(for id: UUID) throws -> Category

    /// Get the category for the given name.
    ///
    /// - Parameters:
    ///   - for: The name of the category as a string.
    /// - Returns: `Category` (if it exists).
    /// - Throws: `ServiceError` on failure.
    func getCategory(for name: String) throws -> Category

    /// Get all the defined categories from the store.
    ///
    /// - Returns: Array of `Category` data.
    /// - Throws: `ServiceError` on failure.
    func getCategories() throws -> [Category]

    /// Get the collection data corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product collection.
    /// - Returns: `ProductCollection` (if it exists).
    /// - Throws: `ServiceError` on failure.
    func getCollection(for id: UUID) throws -> ProductCollection
}
