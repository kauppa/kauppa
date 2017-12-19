import Foundation
import XCTest

import KauppaOrdersClient
import KauppaOrdersModel

public class TestOrdersService: OrdersServiceCallable {
    var order = Order()
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
    public func deleteOrder(id: UUID) throws -> () {
        throw OrdersError.invalidOrder
    }

    // NOTE: Not meant to be called by cart
    public func cancelOrder(id: UUID) throws -> () {
        throw OrdersError.invalidOrder
    }
}
