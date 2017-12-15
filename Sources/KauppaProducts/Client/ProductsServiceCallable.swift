import Foundation

import KauppaProductsModel

/// General API meant for the products service to be used by both the
/// service and the client.
public protocol ProductsServiceCallable {
    /* Product */

    /// Create product with the given product data.
    func createProduct(data: ProductData) throws -> Product

    /// Get product for a given ID.
    func getProduct(id: UUID) throws -> Product

    /// Delete product corresponding to a given ID.
    func deleteProduct(id: UUID) throws -> ()

    /// Update the product corresponding to a given ID.
    func updateProduct(id: UUID, data: ProductPatch) throws -> Product

    /// Adds one or more items to the corresponding collection fields in a product.
    func addProductProperty(id: UUID, data: ProductPropertyAdditionPatch) throws -> Product

    /// Reset individual product properties with the given patch.
    func deleteProductProperty(id: UUID, data: ProductPropertyDeletionPatch) throws -> Product

    /* Product collection */

    /// Create a collection of products with the given data.
    func createCollection(data: ProductCollectionData) throws -> ProductCollection

    /// Update an existing collection with the given patch data.
    func updateCollection(id: UUID, data: ProductCollectionPatch) throws -> ProductCollection

    /// Delete a collection corresponding to the given ID.
    func deleteCollection(id: UUID) throws -> ()
}
