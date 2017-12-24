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

    public func createNewOrder(orderData: Order) throws -> () {
        createCalled = true
        orders[orderData.id] = orderData
        return ()
    }

    public func getOrder(id: UUID) throws -> Order {
        getCalled = true
        guard let order = orders[id] else {
            throw OrdersError.invalidOrder
        }

        return order
    }

    public func updateOrder(data: Order) throws -> () {
        updateCalled = true
        orders[data.id] = data
        return ()
    }

    public func deleteOrder(id: UUID) throws -> () {
        deleteCalled = true
        if orders.removeValue(forKey: id) == nil {
            throw OrdersError.invalidOrder
        }

        return ()
    }

    public func createRefund(data: Refund) throws -> () {
        refundCreated = true
        refunds[data.id] = data
        return ()
    }
}
