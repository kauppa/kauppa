import Foundation

import KauppaCore
import KauppaShipmentsModel

/// Methods that fetch data from the underlying store.
public protocol ShipmentsQuerying: Querying {
    /// Get the shipment data corresponding to an ID.
    func getShipment(for id: UUID) throws -> Shipment
}
