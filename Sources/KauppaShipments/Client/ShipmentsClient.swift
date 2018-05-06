import Foundation

import KauppaCore
import KauppaOrdersModel
import KauppaShipmentsModel

/// HTTP client for the Shipments service.
public class ShipmentsServiceClient<C: ClientCallable>: ServiceClient<C, ShipmentsRoutes>, ShipmentsServiceCallable {
    public func createShipment(for orderId: UUID, with items: [OrderUnit]?) throws -> Shipment {
        let client = try createClient(for: .createShipment, with: ["order": orderId])
        try client.setJSON(using: MappableArray(for: items ?? []))
        return try requestJSON(with: client)
    }

    public func notifyShipping(for id: UUID) throws -> Shipment {
        let client = try createClient(for: .notifyShipping, with: ["id": id])
        return try requestJSON(with: client)
    }

    public func notifyDelivery(for id: UUID) throws -> Shipment {
        let client = try createClient(for: .notifyDelivery, with: ["id": id])
        return try requestJSON(with: client)
    }

    public func schedulePickup(for orderId: UUID, with data: PickupItems) throws -> Shipment {
        let client = try createClient(for: .schedulePickup, with: ["order": orderId])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func completePickup(for id: UUID) throws -> Shipment {
        let client = try createClient(for: .completePickup, with: ["id": id])
        return try requestJSON(with: client)
    }
}
