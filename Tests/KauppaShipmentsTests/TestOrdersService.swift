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
    public func createOrder(data: OrderData) throws -> Order {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by shipments
    public func getOrder(forId id: UUID) throws -> Order {
        if let err = error {
            throw err
        }

        return order
    }

    public func updateShipment(forId id: UUID, data: Shipment) throws -> () {
        if let callback = callback {
            callback(data as Any)
        }

        if let err = error {
            throw err
        }

        return ()
    }

    // NOTE: Not meant to be called by shipments
    public func deleteOrder(id: UUID) throws -> () {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by shipments
    public func cancelOrder(id: UUID) throws -> Order {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by shipments
    public func initiateRefund(forId id: UUID, data: RefundData) throws -> Order {
        throw OrdersError.invalidOrder
    }
}
