import Foundation

import KauppaCore
import KauppaShipmentsModel

/// Methods that mutate the underlying store with information.
public protocol ShipmentsPersisting: Persisting {
    /// Create a shipment with data from the repository.
    ///
    /// - Parameters:
    ///   - with: `Shipment` object.
    /// - Throws: `ServiceError` on failure.
    func createShipment(with data: Shipment) throws -> ()

    /// Update a shipment with data from the repository.
    ///
    /// - Parameters:
    ///   - with: Updated `Shipment` object.
    /// - Throws: `ServiceError` on failure.
    func updateShipment(with data: Shipment) throws -> ()
}
