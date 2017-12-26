import Foundation

import KauppaCore
import KauppaCartModel

/// Methods that fetch data from the underlying store.
public protocol CartQuerying: Querying {
    /// Get the cart associated with an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the cart.
    /// - Returns: The `Cart` if it exists.
    /// - Throws: `CartError` if it doesn't.
    func getCart(for id: UUID) throws -> Cart
}
