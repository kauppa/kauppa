import Foundation
import XCTest

import KauppaAccountsModel
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
}
