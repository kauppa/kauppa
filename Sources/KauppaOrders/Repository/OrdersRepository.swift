import Foundation

import KauppaOrdersModel

public class OrdersRepository {
    var orders = [UUID: Order]()

    func createNewOrder(id: UUID, order: Order) {
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