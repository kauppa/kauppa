import Foundation

import KauppaOrdersModel
import KauppaOrdersStore

public class OrdersRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var orders = [UUID: Order]()

    let store: OrdersStore

    public init(withStore store: OrdersStore) {
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

    /// Delete an order corresponding to an ID.
    public func deleteOrder(id: UUID) throws -> () {
        orders.removeValue(forKey: id)
        return try store.deleteOrder(id: id)
    }
}
