import Foundation

import KauppaCore
import KauppaOrdersModel

/// Methods that mutate the underlying store with information.
public protocol OrdersPersisting: Persisting {
    /// Create a new order with data from the repository.
    func createNewOrder(orderData: Order) throws -> ()

    /// Delete an order corresponding to an ID.
    func deleteOrder(id: UUID) throws -> ()
}
