import Foundation

import KauppaOrdersModel
import KauppaOrdersStore

public class OrdersRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var orders = [UUID: Order]()

    let store: OrdersStorable

    public init(withStore store: OrdersStorable) {
        self.store = store
    }

    /// Create an order with service-supplied order data.
    public func createOrder(withData data: Order) throws -> Order {
        let id = UUID()
        let date = Date()
        var data = data
        data.id = id
        data.createdOn = date
        data.updatedAt = date

        orders[id] = data
        try store.createNewOrder(orderData: data)
        return data
    }

    /// Get an order corresponding to an ID.
    public func getOrder(id: UUID) throws -> Order {
        guard let order = orders[id] else {
            let order = try store.getOrder(id: id)
            orders[id] = order
            return order
        }

        return order
    }

    /// Update an order with the given data from the service.
    public func updateOrder(withData data: Order) throws -> Order {
        var order = data
        order.updatedAt = Date()
        orders[order.id!] = order
        try store.updateOrder(data: order)
        return order
    }

    /// Delete an order corresponding to an ID.
    public func deleteOrder(id: UUID) throws -> () {
        orders.removeValue(forKey: id)
        return try store.deleteOrder(id: id)
    }
}
