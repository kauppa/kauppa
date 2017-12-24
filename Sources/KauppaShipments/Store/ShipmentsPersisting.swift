import Foundation

import KauppaCore
import KauppaShipmentsModel

/// Methods that mutate the underlying store with information.
public protocol ShipmentsPersisting: Persisting {
    /// Create a shipment with data from the repository.
    func createShipment(data: Shipment) throws -> ()
}
