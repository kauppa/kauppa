import Foundation

import KauppaOrdersModel
import KauppaOrdersStore

public class OrdersRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var orders = [UUID: Order]()

    let store: OrdersStore

    public init(withStore store: OrdersStore) {
        self.store = store
    }

    public func createOrder(forProducts products: [OrderedProduct]) -> Order? {
        return nil
    }
}
