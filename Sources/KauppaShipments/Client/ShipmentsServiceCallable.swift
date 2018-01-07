import Foundation

import KauppaShipmentsModel

/// General API for the shipment service to be implemented by both the
/// service and the client.
public protocol ShipmentsServiceCallable {
    /// Create a shipment for an order. This is supposed to queue
    /// the items in the order.
    ///
    /// - Parameters:
    ///   - forOrder: The `UUID` of the order which is to be shipped.
    /// - Returns: `Shipment`
    /// - Throws: `OrdersError` if the order doesn't exist.
    func createShipment(forOrder id: UUID) throws -> Shipment

    /// Change the shipping status to 'shipped' - this also notifies
    /// orders service that the items have been shipped.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of this `Shipment`
    /// - Returns: `Shipment`
    /// - Throws `ShipmentsError` if this shipment cannot be shipped.
    func notifyShipping(id: UUID) throws -> Shipment

    /// Change the shipping status 'delivered' - this also notifies
    /// orders service that the items have been delivered.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of this `Shipment`
    /// - Returns: `Shipment`
    /// - Throws: `ShipmentsError` if the shipment status cannot be changed.
    func notifyDelivery(id: UUID) throws -> Shipment

    /// Schedule a pickup for an order with the item data.
    ///
    /// - Parameters:
    ///   - forOrder: The `UUID` of the order.
    ///   - data: The `PickupItems` data which contains the list of items to be picked up
    /// - Returns: `Shipment`
    /// - Throws: `OrdersError` if the order doesn't exist
    func schedulePickup(forOrder id: UUID, data: PickupItems) throws -> Shipment

    /// Complete picking up items - This means that the items have been
    /// returned to some local warehouse.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of a shipment.
    /// - Returns: Updated `Shipment`
    /// - Throws: `ShipmentsError`
    func completePickup(id: UUID) throws -> Shipment
}
