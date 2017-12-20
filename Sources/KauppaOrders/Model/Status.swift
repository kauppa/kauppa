import KauppaCore

/// Status of a single ordered product (with quantity).
public struct OrderUnitStatus: Mappable {
    /// Quantity sent to the customer.
    public var fulfilledQuantity: UInt8
    /// Status of this ordered unit.
    public var fulfillment: FulfillmentStatus? = nil

    public init(quantity: UInt8) {
        fulfilledQuantity = quantity
    }
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
    /// Payment failed.
    case failed = "failed"

    /// Check the equality of this type.
    public static func ==(lhs: PaymentStatus, rhs: PaymentStatus) -> Bool {
        switch (lhs, rhs) {
            case (.pending, .pending),
                 (.refunded, .refunded),
                 (.partialRefund, .partialRefund),
                 (.paid, .paid),
                 (.failed, .failed):
                return true
            default:
                return false
        }
    }
}

/// Status of an order. This is usually changed by the shipping service.
public enum FulfillmentStatus: String, Mappable {
    /// Order has been successfully placed.
    case fulfilled = "fulfilled"
    /// At least one item has been fulfilled.
    case partial = "partially fulfilled"

    /// Check the equality of this type.
    public static func ==(lhs: FulfillmentStatus, rhs: FulfillmentStatus) -> Bool {
        switch (lhs, rhs) {
            case (.fulfilled, .fulfilled),
                 (.partial, .partial):
                return true
            default:
                return false
        }
    }
}
