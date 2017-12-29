import Foundation
import XCTest

import KauppaOrdersClient
import KauppaOrdersModel
import KauppaShipmentsModel

public class TestOrdersService: OrdersServiceCallable {
    var order = Order(placedBy: UUID())
    var callback: ((OrderData) -> Void)? = nil
    var error: OrdersError? = nil

    public func createOrder(data: OrderData) throws -> Order {
        if let call = callback {
            call(data)
        }
        if let error = error {
            throw error
        }

        return order
    }

    // NOTE: Not meant to be called by cart
    public func getOrder(forId id: UUID) throws -> Order {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by cart
    public func deleteOrder(id: UUID) throws -> () {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by cart
    public func updateShipment(forId id: UUID, data: Shipment) throws -> () {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by cart
    public func cancelOrder(id: UUID) throws -> Order {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by cart
    public func initiateRefund(forId id: UUID, data: RefundData) throws -> Order {
        throw OrdersError.invalidOrder
    }
}
