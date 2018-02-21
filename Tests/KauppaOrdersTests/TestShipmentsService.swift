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

    public func createShipment(for id: UUID) throws -> Shipment {
        if let callback = callback {
            callback(id as Any)
        }

        guard let data = shipment else {
            throw ShipmentsError.invalidShipment
        }

        return data
    }

    public func schedulePickup(for id: UUID, with data: PickupItems) throws -> Shipment {
        if let callback = callback {
            callback((id, data) as Any)
        }

        guard let data = shipment else {
            throw ShipmentsError.invalidShipment
        }

        return data
    }

    // NOTE: Not meant to be called by orders
    public func completePickup(for id: UUID) throws -> Shipment {
        throw ShipmentsError.invalidShipment
    }

    // NOTE: Not meant to be called by orders
    public func notifyShipping(for id: UUID) throws -> Shipment {
        throw ShipmentsError.invalidShipment
    }

    // NOTE: Not meant to be called by orders
    public func notifyDelivery(for id: UUID) throws -> Shipment {
        throw ShipmentsError.invalidShipment
    }
}
