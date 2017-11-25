import Foundation

import KauppaCore
import KauppaOrdersModel

public class OrdersRepository {
    var orders = [UUID: Order]()

    public init() {

    }

    public func createNewOrder(id: UUID, order: Order) {
        orders[id] = order
    }

    func removeOrderIfExists(id: UUID) -> Order? {
        if let order = orders[id] {
            orders.removeValue(forKey: id)
            return order
        } else {
            return nil
        }
    }
}