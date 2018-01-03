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

    /// Initialize this repository with an orders store.
    ///
    /// - Parameters:
    ///   - with: Anything that implements `OrdersStorable`
    public init(with store: OrdersStorable) {
        self.store = store
    }

    /// Create an order with service-supplied order data.
    ///
    /// - Parameters:
    ///   - with: The `Order` object.
    /// - Throws: `ServiceError` on failure.
    public func createOrder(with data: Order) throws {
        orders[data.id] = data
        try store.createNewOrder(with: data)
    }

    /// Get an order corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the order.
    /// - Returns: `Order` object.
    /// - Throws: `ServiceError` on failure.
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
    ///
    /// - Parameters:
    ///   - with: The updated `Order` object.
    /// - Returns: Updated `Order` object.
    /// - Throws: `ServiceError` on failure.
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
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the order.
    /// - Throws: `ServiceError` if the ID is invalid.
    public func deleteOrder(for id: UUID) throws -> () {
        orders.removeValue(forKey: id)
        return try store.deleteOrder(for: id)
    }

    /// Create a refund for an order.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the associated order.
    ///   - with: The reason for this refund.
    ///   - items: The product items and quantities to be refunded.
    ///   - amount: The amount to be refunded.
    /// - Returns: `Refund` object
    /// - Throws: `ServiceError` on failure.
    public func createRefund(for orderId: UUID,
                             with reason: String, items: [CartUnit],
                             amount: UnitMeasurement<Currency>) throws -> Refund
    {
        var refund = Refund(for: orderId, with: reason, amount: amount)
        refund.items = items
        refunds[refund.id] = refund
        try store.createRefund(with: refund)
        return refund
    }
}
