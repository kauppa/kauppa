import Foundation

/// Order service errors
public enum OrdersError: Error {
    case productUnavailable
    case invalidOrder
    case noItemsToProcess
    case ambiguousCurrencies
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
                 (.ambiguousCurrencies, .ambiguousCurrencies):
                return true
            default:
                return false
        }
    }
}
