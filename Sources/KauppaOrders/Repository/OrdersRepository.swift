import Foundation

import KauppaOrdersModel
import KauppaOrdersStore

public class OrdersRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var orders = [UUID: Order]()
    var refunds = [UUID: Refund]()

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
    ///
    /// It takes an optional parameter `skipDate` for skipping
    /// updating the `updatedAt` date object, because `Order` struct
    /// has a lot of fields for indicating different kinds of dates
    /// and we want the dates to be consistent whenever we make a change.
    public func updateOrder(withData data: Order, skipDate: Bool = false) throws -> Order {
        var order = data
        if !skipDate {
            order.updatedAt = Date()
        }

        orders[order.id!] = order
        try store.updateOrder(data: order)
        return order
    }

    /// Delete an order corresponding to an ID.
    public func deleteOrder(id: UUID) throws -> () {
        orders.removeValue(forKey: id)
        return try store.deleteOrder(id: id)
    }

    /// Create a refund for an order.
    public func createRefund(forOrder orderId: UUID,
                             reason: String, items: [OrderUnit]) throws -> Refund
    {
        let id = UUID()
        var refund = Refund(id: UUID(), createdOn: Date(),
                            orderId: orderId, reason: reason)
        refund.items = items
        refunds[id] = refund
        try store.createRefund(data: refund)
        return refund
    }
}
