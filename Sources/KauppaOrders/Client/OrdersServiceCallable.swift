import Foundation

import KauppaOrdersModel
import KauppaShipmentsModel

/// General API for the orders service to be implemented by both the
/// service and the client.
public protocol OrdersServiceCallable {
    /// Create an order from the given order data.
    ///
    /// - Parameters:
    ///   - data: The `OrderData` required for placing an order.
    /// - Returns: An `Order`
    /// - Throws:
    ///   - `AccountsError` if the account doesn't exist
    ///   - `ProductsError` if one of the products doesn't exist
    ///   - `OrdersError` if the order couldn't be placed.
    func createOrder(data: OrderData) throws -> Order

    /// Get an order corresponding to an ID.
    ///
    /// - Parameters:
    ///   - forId: The `UUID` of the `Order`
    /// - Returns: An `Order` (if it exists)
    /// - Throws: `OrdersError` (if it doesn't)
    func getOrder(forId id: UUID) throws -> Order

    /// Cancel an existing order.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the `Order`
    /// - Returns: An `Order` (if it exists)
    /// - Throws: `OrdersError` (if it doesn't)
    func cancelOrder(id: UUID) throws -> Order

    /// Initiate return for a fulfilled order.
    func returnOrder(id: UUID, data: PickupData) throws -> Order

    /// Update shipment for an order.
    ///
    /// - Parameters:
    ///   - forId: The `UUID` of the `Order`
    ///   - `data`: The `Shipment` notification data to update the order.
    /// - Throws: `OrdersError` if the order doesn't exist, or if there were errors.
    func updateShipment(forId id: UUID, data: Shipment) throws -> ()

    /// Initiate refund for an order with the given data.
    ///
    /// - Parameters:
    ///   - forId: The `UUID` of the `Order`
    ///   - data: `RefundData` required for initiating the refund.
    /// - Returns: `Order` with the refund data.
    /// - Throws: `OrdersError` if the order doesn't exist or if there were errors.
    func initiateRefund(forId id: UUID, data: RefundData) throws -> Order

    /// Delete an order corresponding to a given ID.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the `Order`
    /// - Throws: `OrdersError` if the order doesn't exist.
    func deleteOrder(id: UUID) throws -> ()
}
