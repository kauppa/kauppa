import Foundation

import KauppaCore

/// Data required for initiating a refund.
public struct RefundData: Mappable {
    /// Refund all units in the order.
    public let fullRefund: Bool? = nil
    /// Refund specific units in an order.
    public let units: [OrderUnit]? = nil
    /// Reason for requesting this refund.
    public let reason: String
    /// Whether the inventory should be restocked for this refund.
    public let restock: Bool? = nil
}

/// Refund created for an order (or some units in an order).
public struct Refund: Mappable {
    /// Unique identifier for this refund.
    public let id: UUID
    /// Creation date
    public let createdOn: Date
    /// Order to which this refund belongs to.
    public let orderId: UUID
    /// Reason for requesting this refund.
    public let reason: String
    /// Items associated with this refund.
    public var items = [OrderUnit]()

    public init(id: UUID, createdOn: Date, orderId: UUID, reason: String) {
        self.id = id
        self.createdOn = createdOn
        self.orderId = orderId
        self.reason = reason
    }
}
