import Foundation

import KauppaCore
import KauppaCartModel

/// Data required for initiating a refund.
public struct RefundData: Mappable {
    /// Refund all units in the order.
    public var fullRefund: Bool? = nil
    /// Refund specific units in an order.
    public var units: [CartUnit]? = nil
    /// Reason for requesting this refund.
    public let reason: String

    /// Initialize this instance with the refund reason.
    ///
    /// - Parameters:
    ///   - reason: The reason for initiating the refund.
    public init(reason: String) {
        self.reason = reason
    }
}

/// Refund created for an order (or some units in an order).
public struct Refund: Mappable {
    /// Unique identifier for this refund.
    public let id = UUID()
    /// Creation date
    public let createdOn = Date()
    /// Order to which this refund belongs to.
    public let orderId: UUID
    /// Reason for requesting this refund.
    public let reason: String
    /// Items associated with this refund.
    public var items = [CartUnit]()
    /// Refund amount.
    public let amount: UnitMeasurement<Currency>

    /// Initialize this object with the given data.
    ///
    /// - Parameters:
    ///   - for: The ID of the order to which this refund belongs to.
    ///   - with: The reason for initiating this refund.
    ///   - amount: Refund amount.
    public init(for orderId: UUID, with reason: String, amount: UnitMeasurement<Currency>) {
        self.orderId = orderId
        self.reason = reason
        self.amount = amount
    }
}
