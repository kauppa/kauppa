import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaCartModel
import KauppaOrdersModel
import KauppaShipmentsModel
import KauppaShipmentsStore

/// Manages the retrieval and persistance of shipment data from store.
public class ShipmentsRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var shipments = [UUID: Shipment]()
    var store: ShipmentsStorable

    /// Initialize this repository with a shipments store.
    ///
    /// - Parameters:
    ///   - with: Anything that implements `ShipmentsStorable`
    public init(with store: ShipmentsStorable) {
        self.store = store
    }

    /// Create a shipment object for an order.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the associated order.
    ///   - with: The list of items in this shipment.
    ///   - to: The address associated with this shipment.
    ///   - status: (Optional) status for this shipment.
    /// - Returns: `Shipment` object.
    /// - Throws: `ServiceError` on failure.
    public func createShipment(for orderId: UUID, with items: [CartUnit], to address: Address,
                               status: ShipmentStatus? = nil) throws -> Shipment
    {
        var data = Shipment(for: orderId, with: address)
        data.items = items
        if let status = status {
            data.status = status
        }

        try store.createShipment(with: data)
        shipments[data.id] = data
        return data
    }

    /// Get the shipment for a given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the shipment.
    /// - Returns: `Shipment` object (if it exists).
    /// - Throws: `ServiceError` on failure.
    public func getShipment(for id: UUID) throws -> Shipment {
        guard let shipment = shipments[id] else {
            let data = try store.getShipment(for: id)
            shipments[id] = data
            return data
        }

        return shipment
    }

    /// Update shipment with data from the service.
    ///
    /// - Parameters:
    ///   - with: The updated `Shipment` data.
    /// - Returns: `Shipment` object (if it exists).
    /// - Throws: `ServiceError` on failure.
    public func updateShipment(with data: Shipment) throws -> Shipment {
        var shipment = data
        shipment.updatedAt = Date()
        shipments[data.id] = shipment
        try store.updateShipment(with: shipment)
        return shipment
    }
}
