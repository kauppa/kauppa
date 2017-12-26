import Foundation

import KauppaCore
import KauppaShipmentsModel

/// Methods that fetch data from the underlying store.
public protocol ShipmentsQuerying: Querying {
    /// Get the shipment data corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the shipment.
    /// - Returns: `Shipment` object (if it exists).
    /// - Throws: `ShipmentsError` on failure.
    func getShipment(for id: UUID) throws -> Shipment
}
