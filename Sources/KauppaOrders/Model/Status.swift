import KauppaCore

/// Status of a single ordered product (with quantity).
public struct OrderUnitStatus: Mappable {
    /// Quantity sent to the customer.
    public var fulfilledQuantity: UInt8
    /// Status of this ordered unit.
    public var fulfillment: FulfillmentStatus
}

/// Status of payment for an order.
public enum PaymentStatus: String, Mappable {
    /// Payment is pending. Payment might fail in this state.
    case pending = "pending"
    /// Payment has been refunded for this order.
    case refunded = "refunded"
    /// Some of the payments have been refunded.
    case partialRefund = "partially refunded"
    /// Payment was successful.
    case paid = "paid"
}

/// Status of an order.
public enum FulfillmentStatus: String, Mappable {
    /// Order has been successfully placed.
    case fulfilled = "fulfilled"
    /// Order has been cancelled.
    case cancelled = "cancelled"
    /// At least one item has been fulfilled.
    case partial = "partially fulfilled"
}
