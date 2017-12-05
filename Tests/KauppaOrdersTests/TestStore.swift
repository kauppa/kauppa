import Foundation

@testable import KauppaOrdersModel
@testable import KauppaOrdersStore

public class TestStore: OrdersStore {
    public var orders = [UUID: Order]()

    // Variables to indicate the count of function calls
    public var createCalled = false
    public var deleteCalled = false

    public func createNewOrder(orderData: Order) throws -> () {
        createCalled = true
        orders[orderData.id!] = orderData
        return ()
    }

    public func deleteOrder(id: UUID) throws -> () {
        deleteCalled = true
        if orders.removeValue(forKey: id) == nil {
            throw OrdersError.invalidOrder
        }

        return ()
    }
}
