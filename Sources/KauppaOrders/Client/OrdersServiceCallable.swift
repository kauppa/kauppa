import Foundation

import KauppaOrdersModel

public protocol OrdersServiceCallable {
    /// Create an order from the given order data.
    func createOrder(data: OrderData) throws -> Order

    /// Cancel an order corresponding to a given ID.
    func deleteOrder(id: UUID) throws -> ()
}
