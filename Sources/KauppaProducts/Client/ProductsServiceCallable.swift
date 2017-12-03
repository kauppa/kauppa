import Foundation

import KauppaProductsModel

/// General API meant for the products service to be used by both the
/// service and the client.
public protocol ProductsServiceCallable {
    /// Create product with the given product data.
    func createProduct(data: ProductData) -> Product?

    /// Get product for a given ID.
    func getProduct(id: UUID) -> Product?

    /// Delete product corresponding to a given ID.
    func deleteProduct(id: UUID) -> Bool

    /// Update the product corresponding to a given ID.
    func updateProduct(id: UUID, data: ProductPatch) -> Product?
}
