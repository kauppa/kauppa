import Foundation

import KauppaOrdersModel

public protocol OrdersServiceCallable {
    /// Create an order from the given order data.
    func createOrder(data: OrderData) throws -> Order
}
