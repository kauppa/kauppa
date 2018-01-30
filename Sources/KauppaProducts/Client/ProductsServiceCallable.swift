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
    ///   - data: The `ProductData` required for creating a product.
    ///   - from: The `Address` from which this request was originated.
    /// - Returns: `Product`
    /// - Throws: `ProductsError` if there were errors validating the data.
    func createProduct(data: ProductData, from address: Address) throws -> Product

    /// Get product for a given ID.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the `Product`
    ///   - from: The `Address` from which this request was originated.
    /// - Returns: `Product` (if it exists)
    /// - Throws: `ProductsError` (if it doesn't).
    func getProduct(id: UUID, from address: Address) throws -> Product

    /// Delete product corresponding to a given ID.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the `Product`
    /// - Throws: `ProductsError` if the product doesn't exist.
    func deleteProduct(id: UUID) throws -> ()

    /// Update the product corresponding to a given ID.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the `Product`
    ///   - data: The `ProductPatch` data required for updating a product.
    ///   - from: The `Address` from which this request was originated.
    /// - Returns: The updated `Product`
    /// - Throws: `ProductsError` if the product doesn't exist or if there were errors.
    func updateProduct(id: UUID, data: ProductPatch,
                       from address: Address) throws -> Product

    /// Adds one or more items to the corresponding collection fields in a product.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the `Product`
    ///   - data: The `ProductPropertyAdditionPatch` data required for adding
    ///     individual properties.
    ///   - from: The `Address` from which this request was originated.
    /// - Returns: The updated `Product` (if it's been updated successfully)
    /// - Throws: `ProductsError` if the product doesn't exist or if there were errors.
    func addProductProperty(id: UUID, data: ProductPropertyAdditionPatch,
                            from address: Address) throws -> Product

    /// Reset individual product properties with the given patch.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the `Product`
    ///   - data: The `ProductPropertyDeletionPatch` data required for removing
    ///     individual properties.
    ///   - from: The `Address` from which this request was originated.
    /// - Returns: The updated `Product` (if it's been updated successfully)
    /// - Throws: `ProductsError` if the product doesn't exist or if there were errors.
    func deleteProductProperty(id: UUID, data: ProductPropertyDeletionPatch,
                               from address: Address) throws -> Product

    /* Product collection */

    /// Create a collection of products with the given data.
    ///
    /// - Parameters:
    ///   - data: The `ProductCollectionData` required for creating a product collection.
    /// - Returns: `ProductCollection`
    /// - Throws: `ProductsError` if the product(s) are non-existent or if there were errors.
    func createCollection(data: ProductCollectionData) throws -> ProductCollection

    /// Update an existing collection with the given patch data.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the `ProductCollection`
    ///   - data: The `ProductCollectionPatch` data required for updating a collection.
    /// - Returns: Updated `ProductCollection`
    /// - Throws: `ProductsError`
    func updateCollection(id: UUID, data: ProductCollectionPatch) throws -> ProductCollection

    /// Delete a collection corresponding to the given ID.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the `ProductCollection`
    /// - Throws: `ProductsError` if the collection doesn't exist
    func deleteCollection(id: UUID) throws -> ()

    /// Add product(s) to an existing collection.
    ///
    /// - Parameters:
    ///   - toCollection: The `UUID` of the `ProductCollection`
    ///   - data: The `ProductCollectionItemPatch` required for adding product(s).
    /// - Returns: Updated `ProductCollection`
    /// - Throws: `ProductsError` if the collection doesn't exist, or if there were errors.
    func addProduct(toCollection id: UUID, data: ProductCollectionItemPatch) throws -> ProductCollection

    /// Remove product(s) from an existing collection.
    ///
    /// - Parameters:
    ///   - fromCollection: The `UUID` of the `ProductCollection`
    ///   - data: The `ProductCollectionItemPatch` required for removing product(s).
    /// - Returns: Updated `ProductCollection`
    /// - Throws: `ProductsError` if the collection doesn't exist, or if there were errors.
    func removeProduct(fromCollection id: UUID, data: ProductCollectionItemPatch) throws -> ProductCollection
}
