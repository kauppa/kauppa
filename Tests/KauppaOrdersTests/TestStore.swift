import Foundation

@testable import KauppaOrdersModel
@testable import KauppaOrdersStore

public class TestStore: OrdersStore {
    public var orders = [UUID: Order]()

    // Variables to indicate the count of function calls
    public var createCalled = false

    public func createNewOrder(orderData: Order) throws -> () {
        createCalled = true
        orders[orderData.id!] = orderData
        return ()
    }
}
