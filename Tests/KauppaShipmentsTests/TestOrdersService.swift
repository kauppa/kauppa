import Foundation
import XCTest

import KauppaOrdersClient
import KauppaOrdersModel
import KauppaShipmentsModel

public class TestOrdersService: OrdersServiceCallable {
    var order = Order(placedBy: UUID())
    var callback: ((Any) -> Void)? = nil
    var error: OrdersError? = nil

    // NOTE: Not meant to be called by shipments
    public func createOrder(with data: OrderData) throws -> Order {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by shipments
    public func getOrder(for id: UUID) throws -> Order {
        if let err = error {
            throw err
        }

        return order
    }

    public func updateShipment(for id: UUID, with data: Shipment) throws -> () {
        if let callback = callback {
            callback((id, data) as Any)
        }

        if let err = error {
            throw err
        }
    }

    // NOTE: Not meant to be called by shipments
    public func returnOrder(for id: UUID, with data: PickupData) throws -> Order {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by shipments
    public func deleteOrder(for id: UUID) throws -> () {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by shipments
    public func cancelOrder(for id: UUID) throws -> Order {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by shipments
    public func initiateRefund(for id: UUID, with data: RefundData) throws -> Order {
        throw OrdersError.invalidOrder
    }
}
