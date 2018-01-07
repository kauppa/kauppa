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
    case invalidDeliveryQuantity(UUID, UInt8)
    case invalidRefundQuantity(UUID, UInt8)
    case invalidReturnQuantity(UUID, UInt8)
    case invalidPickupQuantity(UUID, UInt8)
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
            case .invalidDeliveryQuantity(let id, let existing):
                return "Only \(existing) item(s) can be delivered for product \(id)"
            case .invalidRefundQuantity(let id, let existing):
                if existing > 0 {
                    return "Only \(existing) item(s) can be refunded for product \(id)"
                } else {
                    return "None of the remaining items can be refunded for product \(id)"
                }
            case .invalidReturnQuantity(let id, let existing):
                if existing > 0 {
                    return "Only \(existing) item(s) have been fulfilled for product \(id)"
                } else {
                    return "No fulfilled items remaining for product \(id)"
                }
            case .invalidPickupQuantity(let id, let existing):
                if existing > 0 {
                    return "Only \(existing) item(s) of product \(id) have been scheduled for pickup"
                } else {
                    return "No items in product \(id) have been scheduled for pickup"
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
            case let (.invalidRefundQuantity(p1, e1), .invalidRefundQuantity(p2, e2)),
                 let (.invalidPickupQuantity(p1, e1), .invalidPickupQuantity(p2, e2)),
                 let (.invalidReturnQuantity(p1, e1), .invalidReturnQuantity(p2, e2)),
                 let (.invalidDeliveryQuantity(p1, e1), .invalidDeliveryQuantity(p2, e2)):
                return e1 == e2 && p1 == p2
            case let (.unfulfilledItem(p1), .unfulfilledItem(p2)):
                return p1 == p2
            default:
                return false
        }
    }
}
