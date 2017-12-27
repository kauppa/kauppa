import Foundation

import KauppaAccountsModel
import KauppaProductsModel

/// General API meant for the products service to be used by both the
/// service and the client.
public protocol ProductsServiceCallable {
    /* Product */

    /// Create product with the given product data.
    ///
    /// - Parameters:
    ///   - with: The `ProductData` required for creating a product.
    ///   - from: (Optional) `Address` from which this request was originated.
    /// - Returns: `Product`
    /// - Throws: `ServiceError` if there were errors validating the data.
    func createProduct(with data: ProductData, from address: Address?) throws -> Product

    /// Get product for a given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `Product`
    ///   - from: (Optional) `Address` from which this request was originated.
    /// - Returns: `Product` (if it exists).
    /// - Throws: `ServiceError` (if it doesn't).
    func getProduct(for id: UUID, from address: Address?) throws -> Product

    /// Delete product corresponding to a given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `Product`
    /// - Throws: `ServiceError` if the product doesn't exist.
    func deleteProduct(for id: UUID) throws -> ()

    /// Update the product corresponding to a given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `Product`
    ///   - with: The `ProductPatch` data required for updating a product.
    ///   - from: (Optional) `Address` from which this request was originated.
    /// - Returns: The updated `Product`
    /// - Throws: `ServiceError` if the product doesn't exist or if there were errors.
    func updateProduct(for id: UUID, with data: ProductPatch,
                       from address: Address?) throws -> Product

    /// Adds one or more items to the corresponding collection fields in a product.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `Product`
    ///   - with: The `ProductPropertyAdditionPatch` data required for adding
    ///     individual properties.
    ///   - from: (Optional) `Address` from which this request was originated.
    /// - Returns: The updated `Product` (if it's been updated successfully)
    /// - Throws: `ServiceError` if the product doesn't exist or if there were errors.
    func addProductProperty(for id: UUID, with data: ProductPropertyAdditionPatch,
                            from address: Address?) throws -> Product

    /// Reset individual product properties with the given patch.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `Product`
    ///   - with: The `ProductPropertyDeletionPatch` data required for removing
    ///     individual properties.
    ///   - from: (Optional) `Address` from which this request was originated.
    /// - Returns: The updated `Product` (if it's been updated successfully)
    /// - Throws: `ServiceError` if the product doesn't exist or if there were errors.
    func deleteProductProperty(for id: UUID, with data: ProductPropertyDeletionPatch,
                               from address: Address?) throws -> Product

    /* Product collection */

    /// Create a collection of products with the given data.
    ///
    /// - Parameters:
    ///   - with: The `ProductCollectionData` required for creating a product collection.
    /// - Returns: `ProductCollection`
    /// - Throws: `ServiceError` if the product(s) are non-existent or if there were errors.
    func createCollection(with data: ProductCollectionData) throws -> ProductCollection

    /// Update an existing collection with the given patch data.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `ProductCollection`
    ///   - with: The `ProductCollectionPatch` data required for updating a collection.
    /// - Returns: Updated `ProductCollection`
    /// - Throws: `ServiceError`
    func updateCollection(for id: UUID, with data: ProductCollectionPatch) throws -> ProductCollection

    /// Delete a collection corresponding to the given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `ProductCollection`
    /// - Throws: `ServiceError` if the collection doesn't exist
    func deleteCollection(for id: UUID) throws -> ()

    /// Add product(s) to an existing collection.
    ///
    /// - Parameters:
    ///   - to: The `UUID` of the `ProductCollection`
    ///   - using: The `ProductCollectionItemPatch` required for adding product(s).
    /// - Returns: Updated `ProductCollection`
    /// - Throws: `ServiceError` if the collection doesn't exist, or if there were errors.
    func addProduct(to id: UUID, using data: ProductCollectionItemPatch) throws -> ProductCollection

    /// Remove product(s) from an existing collection.
    ///
    /// - Parameters:
    ///   - from: The `UUID` of the `ProductCollection`
    ///   - using: The `ProductCollectionItemPatch` required for removing product(s).
    /// - Returns: Updated `ProductCollection`
    /// - Throws: `ServiceError` if the collection doesn't exist, or if there were errors.
    func removeProduct(from id: UUID, using data: ProductCollectionItemPatch) throws -> ProductCollection
}
