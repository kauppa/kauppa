import Foundation

import KauppaCore
import KauppaOrdersModel

/// Methods that mutate the underlying store with information.
public protocol OrdersPersisting: Persisting {
    /// Create a new order with data from the repository.
    ///
    /// - Parameters:
    ///   - with: The `Order` data object.
    /// - Throws: `ServiceError` on failure.
    func createNewOrder(with data: Order) throws -> ()

    /// Update an existing order with data from repository.
    ///
    /// - Parameters:
    ///   - with: The `Order` data object.
    /// - Throws: `ServiceError` on failure.
    func updateOrder(with data: Order) throws -> ()

    /// Delete an order corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the order.
    /// - Throws: `ServiceError` on failure.
    func deleteOrder(for id: UUID) throws -> ()

    /// Create a refund with data from repository.
    ///
    /// - Parameters:
    ///   - with: The `Refund` data object.
    /// - Throws: `ServiceError` on failure.
    func createRefund(with data: Refund) throws -> ()
}
