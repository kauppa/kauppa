import Foundation

import KauppaShipmentsModel

/// General API for the shipment service to be implemented by both the
/// service and the client.
public protocol ShipmentsServiceCallable {
    /// Create a shipment for an order. This is supposed to queue
    /// the items in the order.
    func createShipment(forOrder id: UUID) throws -> Shipment
}
