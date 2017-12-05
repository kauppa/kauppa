import Foundation

/// Order service errors
public enum OrdersError: Error {
    case productUnavailable
    case invalidOrder
    case noItemsToProcess
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
        }
    }
}
