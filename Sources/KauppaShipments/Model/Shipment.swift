import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaCartModel
import KauppaOrdersModel

/// Shipment data that exists in repository and store.
public struct Shipment: Mappable {
    /// Unique identifier for this shipment.
    public let id = UUID()
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// Order to which this shipment is bound.
    public let orderId: UUID
    /// Shipping address for the order.
    public let address: Address
    /// Items from the order.
    public var items = [CartUnit]()
    /// Status of this shipment.
    public var status = ShipmentStatus.shipping

    /// Initialize an instance for the given order and shipping address.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the associated order.
    ///   - with: The `Address` of this shipment.
    public init(for orderId: UUID, with address: Address) {
        let date = Date()
        self.createdOn = date
        self.updatedAt = date
        self.orderId = orderId
        self.address = address
    }

    /// Empty init (for testing)
    init() {
        self.init(for: UUID(), with: Address())
    }
}
