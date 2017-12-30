import Foundation

/// Order service errors
public enum OrdersError: Error {
    case productUnavailable
    case invalidOrder
    case noItemsToProcess
    case ambiguousCurrencies
    case paymentNotReceived
    case cancelledOrder
    case refundedOrder
    case refundedItem
    case invalidReason
    case invalidOrderItem
    case unfulfilledItem(UUID)
    case invalidOrderQuantity(UUID, UInt8)
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
            case .paymentNotReceived:
                return "Payment not received for the order"
            case .cancelledOrder:
                return "Order has been cancelled"
            case .refundedOrder:
                return "Order has been refunded"
            case .refundedItem:
                return "Product item has been refunded"
            case .invalidReason:
                return "Invalid reason for returning/refunding order"
            case .invalidOrderItem:
                return "Item not found in order"
            case .unfulfilledItem(let id):
                return "Items in product \(id) are been fulfilled and cannot be returned/refunded"
            case .invalidOrderQuantity(let id, let existing):
                if existing > 0 {
                    return "Only \(existing) item(s) have been fulfilled for product \(id)"
                } else {
                    return "No fulfilled items remaining for product \(id)"
                }
        }
    }
}

extension OrdersError: Equatable {
    /// Check the equality of this result.
    public static func ==(lhs: OrdersError, rhs: OrdersError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidOrder, .invalidOrder),
                 (.productUnavailable, .productUnavailable),
                 (.noItemsToProcess, .noItemsToProcess),
                 (.ambiguousCurrencies, .ambiguousCurrencies),
                 (.paymentNotReceived, .paymentNotReceived),
                 (.cancelledOrder, .cancelledOrder),
                 (.refundedOrder, .refundedOrder),
                 (.refundedItem, .refundedItem),
                 (.invalidReason, .invalidReason),
                 (.invalidOrderItem, .invalidOrderItem):
                return true
            case let (.invalidOrderQuantity(p1, e1), .invalidOrderQuantity(p2, e2)):
                return e1 == e2 && p1 == p2
            case let (.unfulfilledItem(p1), .unfulfilledItem(p2)):
                return p1 == p2
            default:
                return false
        }
    }
}
