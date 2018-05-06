import Foundation
import XCTest

import KauppaCore
import KauppaAccountsModel
import KauppaCartModel
import KauppaOrdersModel
import KauppaShipmentsClient
import KauppaShipmentsModel

public class TestShipmentsService: ShipmentsServiceCallable {
    public var shipment: Shipment? = Shipment(for: UUID(), with: Address())
    public var callback: ((Any) -> Void)? = nil

    public func createShipment(for id: UUID, with items: [OrderUnit]?) throws -> Shipment {
        guard let data = shipment else {
            throw ServiceError.invalidShipmentId
        }

        return data
    }

    public func schedulePickup(for id: UUID, with data: PickupItems) throws -> Shipment {
        if let callback = callback {
            callback((id, data) as Any)
        }

        guard let data = shipment else {
            throw ServiceError.invalidShipmentId
        }

        return data
    }

    // NOTE: Not meant to be called by orders
    public func completePickup(for id: UUID) throws -> Shipment {
        throw ServiceError.invalidShipmentId
    }

    // NOTE: Not meant to be called by orders
    public func notifyShipping(for id: UUID) throws -> Shipment {
        throw ServiceError.invalidShipmentId
    }

    // NOTE: Not meant to be called by orders
    public func notifyDelivery(for id: UUID) throws -> Shipment {
        throw ServiceError.invalidShipmentId
    }
}
