import KauppaCore

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
