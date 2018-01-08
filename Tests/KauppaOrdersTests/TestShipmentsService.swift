import Foundation
import XCTest

import KauppaAccountsModel
import KauppaOrdersModel
import KauppaShipmentsClient
import KauppaShipmentsModel

public class TestShipmentsService: ShipmentsServiceCallable {
    public var shipment: Shipment? = Shipment(id: UUID(), createdOn: Date(), updatedAt: Date(),
                                              orderId: UUID(), address: Address())
    public var callback: ((Any) -> Void)? = nil

    public func createShipment(forOrder id: UUID) throws -> Shipment {
        if let callback = callback {
            callback(id as Any)
        }

        guard let data = shipment else {
            throw ShipmentsError.invalidShipment
        }

        return data
    }

    public func schedulePickup(forOrder id: UUID, data: PickupItems) throws -> Shipment {
        if let callback = callback {
            callback((id, data) as Any)
        }

        guard let data = shipment else {
            throw ShipmentsError.invalidShipment
        }

        return data
    }

    // NOTE: Not meant to be called by orders
    public func completePickup(id: UUID) throws -> Shipment {
        throw ShipmentsError.invalidShipment
    }

    // NOTE: Not meant to be called by orders
    public func notifyShipping(id: UUID) throws -> Shipment {
        throw ShipmentsError.invalidShipment
    }

    // NOTE: Not meant to be called by orders
    public func notifyDelivery(id: UUID) throws -> Shipment {
        throw ShipmentsError.invalidShipment
    }
}
