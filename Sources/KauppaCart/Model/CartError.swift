import Foundation

/// Cart service errors
public enum CartError: Error {
    /// This is probably returned by the store, when there was an internal error
    /// while trying to get the cart.
    case cartUnavailable
    /// Happens when an action requires item(s) to be present in the cart, but
    /// there aren't any.
    case noItemsInCart
    /// Indicates that we don't have anything process from the given input data.
    case noItemsToProcess
    /// The product doesn't exist in the inventory.
    case productUnavailable
    /// This occurs when the currencies collide across items in the cart.
    /// (i.e., when one product is in USD and the other one is in EUR, for example)
    case ambiguousCurrencies
    /// Occurs when the given address index leads to "out of bounds" in the account data.
    case invalidAddress
}

extension CartError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .cartUnavailable:
                return "Cart unavailable at the moment"
            case .noItemsInCart:
                return "No items in cart"
            case .noItemsToProcess:
                return "No items to process"
            case .productUnavailable:
                return "Product unavailable in inventory"
            case .ambiguousCurrencies:
                return "Cannot add product with a different currency"
            case .invalidAddress:
                return "Invalid shipping/billing address"
        }
    }
}

extension CartError {
    /// Check the equality of this result.
    public static func ==(lhs: CartError, rhs: CartError) -> Bool {
        switch (lhs, rhs) {
            case (.productUnavailable, .productUnavailable),
                 (.noItemsToProcess, .noItemsToProcess),
                 (.noItemsInCart, .noItemsInCart),
                 (.cartUnavailable, .cartUnavailable),
                 (.ambiguousCurrencies, .ambiguousCurrencies),
                 (.invalidAddress, .invalidAddress):
                return true
            default:
                return false
        }
    }
}
