import Foundation

import KauppaCore
import KauppaShipmentsModel

/// A no-op store for shipments which doesn't support data persistence/querying.
/// This way, the repository takes care of all service requests by providing
/// in-memory data.
public class ShipmentsNoOpStore: ShipmentsStorable {
    public init() {}

    public func createShipment(with data: Shipment) throws -> () {}

    public func updateShipment(with data: Shipment) throws -> () {}

    public func getShipment(for id: UUID) throws -> Shipment {
        throw ServiceError.invalidShipmentId
    }
}
