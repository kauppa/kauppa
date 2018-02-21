import Foundation

@testable import KauppaOrdersModel
@testable import KauppaOrdersStore

public class TestStore: OrdersStorable {
    public var orders = [UUID: Order]()
    public var refunds = [UUID: Refund]()

    // Variables to indicate the count of function calls
    public var createCalled = false
    public var getCalled = false
    public var deleteCalled = false
    public var updateCalled = false
    public var refundCreated = false

    public func createNewOrder(with data: Order) throws -> () {
        createCalled = true
        orders[data.id] = data
    }

    public func getOrder(for id: UUID) throws -> Order {
        getCalled = true
        guard let order = orders[id] else {
            throw OrdersError.invalidOrder
        }

        return order
    }

    public func updateOrder(with data: Order) throws -> () {
        updateCalled = true
        orders[data.id] = data
    }

    public func deleteOrder(for id: UUID) throws -> () {
        deleteCalled = true
        if orders.removeValue(forKey: id) == nil {
            throw OrdersError.invalidOrder
        }
    }

    public func createRefund(with data: Refund) throws -> () {
        refundCreated = true
        refunds[data.id] = data
    }
}
