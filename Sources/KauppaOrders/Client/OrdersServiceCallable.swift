import Foundation

import KauppaOrdersModel
import KauppaShipmentsModel

/// General API for the orders service to be implemented by both the
/// service and the client.
public protocol OrdersServiceCallable {
    /// Create an order from the given order data.
    func createOrder(data: OrderData) throws -> Order

    /// Get an order corresponding to an ID.
    func getOrder(forId id: UUID) throws -> Order

    /// Cancel an existing order.
    func cancelOrder(id: UUID) throws -> Order

    /// Update shipment for an order.
    func updateShipment(forId id: UUID, data: Shipment) throws -> ()

    /// Initiate refund for an order with the given data.
    func initiateRefund(forId id: UUID, data: RefundData) throws -> Order

    /// Delete an order corresponding to a given ID.
    func deleteOrder(id: UUID) throws -> ()
}
