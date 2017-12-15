import Foundation

/// Cart service errors
public enum CartError: Error {
    case cartUnavailable
    case noItemsToProcess
    case productUnavailable
    case ambiguousCurrencies
}

extension CartError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .cartUnavailable:
                return "Cart unavailable at the moment"
            case .noItemsToProcess:
                return "No items to process"
            case .productUnavailable:
                return "Product unavailable in inventory"
            case .ambiguousCurrencies:
                return "Cannot add product with a different currency"
        }
    }
}

extension CartError {
    /// Check the equality of this result.
    public static func ==(lhs: CartError, rhs: CartError) -> Bool {
        switch (lhs, rhs) {
            case (.productUnavailable, .productUnavailable),
                 (.noItemsToProcess, .noItemsToProcess),
                 (.ambiguousCurrencies, .ambiguousCurrencies):
                return true
            default:
                return false
        }
    }
}
