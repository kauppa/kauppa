import Foundation

import KauppaCore
import KauppaOrdersModel

/// Shipment data that exists in repository and store.
public struct Shipment: Mappable {
    /// Unique identifier for this shipment.
    public let id: UUID
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// Order to which this shipment is bound.
    public let orderId: UUID
    /// Items from the order.
    public var items = [OrderUnit]()
    /// Status of this shipment.
    public var status = ShipmentStatus.shipping

    public init(id: UUID, createdOn: Date, updatedAt: Date, orderId: UUID) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = updatedAt
        self.orderId = orderId
    }
}
