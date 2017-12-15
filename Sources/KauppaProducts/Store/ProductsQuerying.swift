import Foundation

import KauppaCore
import KauppaProductsModel

/// Methods that simply reference the store for information.
public protocol ProductsQuerying: Querying {
    /// Get the product data corresponding to an ID.
    func getProduct(id: UUID) throws -> Product

    /// Get the collection data corresponding to an ID.
    func getCollection(id: UUID) throws -> ProductCollection
}
