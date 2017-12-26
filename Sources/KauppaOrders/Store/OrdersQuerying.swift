import Foundation

import KauppaCore
import KauppaOrdersModel

/// Methods that simply reference the store for information.
public protocol OrdersQuerying: Querying {
    /// Get an order associated with the given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the order.
    /// - Returns: `Order` data object (if it exists).
    /// - Throws: `OrdersError` on failure.
    func getOrder(for id: UUID) throws -> Order
}
