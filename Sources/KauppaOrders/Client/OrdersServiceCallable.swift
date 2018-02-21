import Foundation

import KauppaOrdersModel
import KauppaShipmentsModel

/// General API for the orders service to be implemented by both the
/// service and the client.
public protocol OrdersServiceCallable {
    /// Create an order from the given order data.
    ///
    /// - Parameters:
    ///   - with: The `OrderData` required for placing an order.
    /// - Returns: An `Order`
    /// - Throws:
    ///   - `AccountsError` if the account doesn't exist
    ///   - `ProductsError` if one of the products doesn't exist
    ///   - `OrdersError` if the order couldn't be placed.
    func createOrder(with data: OrderData) throws -> Order

    /// Get an order corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `Order`
    /// - Returns: An `Order` (if it exists)
    /// - Throws: `OrdersError` (if it doesn't)
    func getOrder(for id: UUID) throws -> Order

    /// Cancel an existing order.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `Order`
    /// - Returns: An `Order` (if it exists)
    /// - Throws: `OrdersError` (if it doesn't)
    func cancelOrder(for id: UUID) throws -> Order

    /// Initiate return for a fulfilled order.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `Order`
    ///   - with: The `PickupData` containing the items for pickup.
    /// - Returns: `Order` with pickup items set
    /// - Throws: `OrdersError` if there were errors while checking the data.
    func returnOrder(for id: UUID, with data: PickupData) throws -> Order

    /// Update shipment for an order.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `Order`
    ///   - with: The `Shipment` notification data to update the order.
    /// - Throws: `OrdersError` if the order doesn't exist, or if there were errors.
    func updateShipment(for id: UUID, with data: Shipment) throws -> ()

    /// Initiate refund for an order with the given data.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `Order`
    ///   - with: `RefundData` required for initiating the refund.
    /// - Returns: `Order` with the refund data.
    /// - Throws: `OrdersError` if the order doesn't exist or if there were errors.
    func initiateRefund(for id: UUID, with data: RefundData) throws -> Order

    /// Delete an order corresponding to a given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the `Order`
    /// - Throws: `OrdersError` if the order doesn't exist.
    func deleteOrder(for id: UUID) throws -> ()
}
