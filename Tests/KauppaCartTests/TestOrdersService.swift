import Foundation
import XCTest

import KauppaOrdersClient
import KauppaOrdersModel
import KauppaShipmentsModel

public class TestOrdersService: OrdersServiceCallable {
    var order = Order(placedBy: UUID())
    var callback: ((OrderData) -> Void)? = nil
    var error: OrdersError? = nil

    public func createOrder(with data: OrderData) throws -> Order {
        if let call = callback {
            call(data)
        }
        if let error = error {
            throw error
        }

        return order
    }

    // NOTE: Not meant to be called by cart
    public func getOrder(for id: UUID) throws -> Order {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by cart
    public func deleteOrder(for id: UUID) throws -> () {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by cart
    public func updateShipment(for id: UUID, with data: Shipment) throws -> () {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by cart
    public func returnOrder(for id: UUID, with data: PickupData) throws -> Order {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by cart
    public func cancelOrder(for id: UUID) throws -> Order {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by cart
    public func initiateRefund(for id: UUID, with data: RefundData) throws -> Order {
        throw OrdersError.invalidOrder
    }
}
