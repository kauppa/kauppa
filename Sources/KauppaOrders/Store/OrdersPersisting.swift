import Foundation

import KauppaCore
import KauppaOrdersModel

/// Methods that mutate the underlying store with information.
public protocol OrdersPersisting: Persisting {
    /// Create a new order with data from the repository.
    func createNewOrder(with data: Order) throws -> ()

    /// Update an existing order with data from repository.
    func updateOrder(with data: Order) throws -> ()

    /// Delete an order corresponding to an ID.
    func deleteOrder(for id: UUID) throws -> ()

    /// Create a refund with data from repository.
    func createRefund(with data: Refund) throws -> ()
}
