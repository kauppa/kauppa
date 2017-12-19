import Foundation

/// Order service errors
public enum OrdersError: Error {
    case productUnavailable
    case invalidOrder
    case noItemsToProcess
    case ambiguousCurrencies
    case processingPayment
    case cancelledOrder
    case refundedOrder
    case refundedItem
    case invalidRefundReason
}

extension OrdersError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .productUnavailable:
                return "Not enough products in inventory"
            case .noItemsToProcess:
                return "No items to be processed"
            case .invalidOrder:
                return "No order found for the given UUID"
            case .ambiguousCurrencies:
                return "One or more products have different currencies"
            case .processingPayment:
                return "Payment is still being processed"
            case .cancelledOrder:
                return "Order has been cancelled"
            case .refundedOrder:
                return "Order has been refunded"
            case .refundedItem:
                return "Product item has been refunded"
            case .invalidRefundReason:
                return "Invalid reason for initiating refund"
        }
    }
}

extension OrdersError {
    /// Check the equality of this result.
    public static func ==(lhs: OrdersError, rhs: OrdersError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidOrder, .invalidOrder),
                 (.productUnavailable, .productUnavailable),
                 (.noItemsToProcess, .noItemsToProcess),
                 (.ambiguousCurrencies, .ambiguousCurrencies),
                 (.processingPayment, .processingPayment),
                 (.cancelledOrder, .cancelledOrder),
                 (.refundedOrder, .refundedOrder),
                 (.refundedItem, .refundedItem),
                 (.invalidRefundReason, .invalidRefundReason):
                return true
            default:
                return false
        }
    }
}
