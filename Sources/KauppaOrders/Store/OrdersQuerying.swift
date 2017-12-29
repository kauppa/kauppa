import Foundation

import KauppaCore
import KauppaOrdersModel

/// Methods that simply reference the store for information.
public protocol OrdersQuerying: Querying {
    /// Get an order associated with the given ID.
    func getOrder(id: UUID) throws -> Order
}
