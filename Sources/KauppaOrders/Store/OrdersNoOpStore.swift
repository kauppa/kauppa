import Foundation

import KauppaCore
import KauppaOrdersModel

/// A no-op store for orders which doesn't support data persistence/querying.
/// This way, the repository takes care of all service requests by providing
/// in-memory data.
public class OrdersNoOpStore: OrdersStorable {
    public init() {}

    public func createOrder(with data: Order) throws -> () {}

    public func getOrder(for id: UUID) throws -> Order {
        throw ServiceError.invalidOrderId
    }

    public func updateOrder(with data: Order) throws -> () {}

    public func deleteOrder(for id: UUID) throws -> () {
        throw ServiceError.invalidOrderId
    }

    public func createRefund(with data: Refund) throws -> () {}
}
