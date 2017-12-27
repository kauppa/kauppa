import Foundation

import KauppaCore
import KauppaProductsModel

/// Methods that mutate the underlying store with information.
public protocol ProductsPersisting: Persisting {
    /// Create a new product with the product information from repository.
    ///
    /// - Parameters:
    ///   - with: The `Product` object from the repository.
    /// - Throws: `ServiceError` on failure.
    func createNewProduct(with data: Product) throws -> ()

    /// Delete a product corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product.
    /// - Throws: `ServiceError` on failure.
    func deleteProduct(for id: UUID) throws -> ()

    /// Update a product with the product information. ID will be obtained
    /// from the data.
    ///
    /// - Parameters:
    ///   - with: The updated `Product` object from the repository.
    /// - Throws: `ServiceError` on failure.
    func updateProduct(with data: Product) throws -> ()

    /// Create an attribute using the given data.
    ///
    /// - Parameters:
    ///   - with: `Attribute` object from repository.
    /// - Throws: `ServiceError` on failure.
    func createAttribute(with data: Attribute) throws -> ()

    /// Create a new collection with information from the repository.
    ///
    /// - Parameters:
    ///   - with: `ProductCollection` object from repository.
    /// - Throws: `ServiceError` on failure.
    func createNewCollection(with data: ProductCollection) throws -> ()

    /// Update an existing collection with data from repository.
    ///
    /// - Parameters:
    ///   - with: Updated `ProductCollection` from repository.
    /// - Throws: `ServiceError` on failure.
    func updateCollection(with data: ProductCollection) throws -> ()

    /// Delete a collection corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product collection.
    /// - Throws: `ServiceError` on failure.
    func deleteCollection(for id: UUID) throws -> ()
}
