import Foundation

/// Cart service errors
public enum CartError: Error {
    case invalidCartId
}

extension CartError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .invalidCartId:
                return "No cart associated with this UUID"
        }
    }
}

extension CartError {
    /// Check the equality of this result.
    public static func ==(lhs: CartError, rhs: CartError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidCartId, .invalidCartId):
                return true
            // default:
            //     return false
        }
    }
}
