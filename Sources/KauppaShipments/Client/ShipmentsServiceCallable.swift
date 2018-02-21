import Foundation

import KauppaShipmentsModel

/// General API for the shipment service to be implemented by both the
/// service and the client.
public protocol ShipmentsServiceCallable {
    /// Create a shipment for an order. This is supposed to queue
    /// the items in the order.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the order which is to be shipped.
    /// - Returns: `Shipment`
    /// - Throws: `OrdersError` if the order doesn't exist.
    func createShipment(for id: UUID) throws -> Shipment

    /// Change the shipping status to 'shipped' - this also notifies
    /// orders service that the items have been shipped.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of this `Shipment`
    /// - Returns: `Shipment`
    /// - Throws `ShipmentsError` if this shipment cannot be shipped.
    func notifyShipping(for id: UUID) throws -> Shipment

    /// Change the shipping status 'delivered' - this also notifies
    /// orders service that the items have been delivered.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of this `Shipment`
    /// - Returns: `Shipment`
    /// - Throws: `ShipmentsError` if the shipment status cannot be changed.
    func notifyDelivery(for id: UUID) throws -> Shipment

    /// Schedule a pickup for an order with the item data.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the order.
    ///   - with: The `PickupItems` data which contains the list of items to be picked up
    /// - Returns: `Shipment`
    /// - Throws: `OrdersError` if the order doesn't exist
    func schedulePickup(for id: UUID, with data: PickupItems) throws -> Shipment

    /// Complete picking up items - This means that the items have been
    /// returned to some local warehouse.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of a shipment.
    /// - Returns: Updated `Shipment`
    /// - Throws: `ShipmentsError`
    func completePickup(for id: UUID) throws -> Shipment
}
