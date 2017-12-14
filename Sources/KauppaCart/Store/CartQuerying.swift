import Foundation

import KauppaCore
import KauppaCartModel

/// Methods that fetch data from the underlying store.
public protocol CartQuerying: Querying {
    /// Get the cart associated with an ID.
    func getCart(id: UUID) throws -> Cart
}
