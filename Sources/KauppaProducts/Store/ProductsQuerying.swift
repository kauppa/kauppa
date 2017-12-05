import Foundation

import KauppaProductsModel

/// Methods that simply reference the store for information.
public protocol ProductsQuerying {
    /// Get the product data corresponding to an ID.
    func getProduct(id: UUID) throws -> Product
}
