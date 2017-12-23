import Foundation

import KauppaCore
import KauppaOrdersModel
import KauppaShipmentsModel
import KauppaShipmentsStore

/// Manages the retrieval and persistance of shipment data from store.
public class ShipmentsRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var shipments = [UUID: Shipment]()
    var store: ShipmentsStorable

    public init(withStore store: ShipmentsStorable) {
        self.store = store
    }

    /// Create a shipment object for an order.
    public func createShipment(forOrder id: UUID, items: [OrderUnit]) throws -> Shipment {
        let date = Date()
        var data = Shipment(id: UUID(), createdOn: date, updatedAt: date, orderId: id)
        data.items = items
        try store.createShipment(data: data)
        shipments[data.id] = data
        return data
    }
}
