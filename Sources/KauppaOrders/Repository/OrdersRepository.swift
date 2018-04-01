import Foundation

import KauppaCore
import KauppaCartModel
import KauppaOrdersModel
import KauppaOrdersStore

public class OrdersRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var orders = [UUID: Order]()
    var refunds = [UUID: Refund]()

    let store: OrdersStorable

    public init(with store: OrdersStorable) {
        self.store = store
    }

    /// Create an order with service-supplied order data.
    public func createOrder(with data: Order) throws {
        orders[data.id] = data
        try store.createNewOrder(with: data)
    }

    /// Get an order corresponding to an ID.
    public func getOrder(for id: UUID) throws -> Order {
        guard let order = orders[id] else {
            let order = try store.getOrder(for: id)
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
    public func updateOrder(with data: Order, skippingDate: Bool = false) throws -> Order {
        var order = data
        if !skippingDate {
            order.updatedAt = Date()
        }

        orders[order.id] = order
        try store.updateOrder(with: order)
        return order
    }

    /// Delete an order corresponding to an ID.
    public func deleteOrder(for id: UUID) throws -> () {
        orders.removeValue(forKey: id)
        return try store.deleteOrder(for: id)
    }

    /// Create a refund for an order.
    public func createRefund(for orderId: UUID,
                             with reason: String, items: [CartUnit],
                             amount: UnitMeasurement<Currency>) throws -> Refund
    {
        let id = UUID()
        var refund = Refund(id: UUID(), createdOn: Date(),
                            orderId: orderId, reason: reason, amount: amount)
        refund.items = items
        refunds[id] = refund
        try store.createRefund(with: refund)
        return refund
    }
}
