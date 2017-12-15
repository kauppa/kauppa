import Foundation

/// Products service errors
public enum ProductsError: Error {
    case invalidProduct
    case invalidCollection
}

extension ProductsError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .invalidProduct:
                return "No product found for the given UUID"
            case .invalidCollection:
                return "No collection found for the given UUID"
        }
    }
}

extension ProductsError {
    /// Check the equality of this result.
    public static func ==(lhs: ProductsError, rhs: ProductsError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidProduct, .invalidProduct),
                 (.invalidCollection, .invalidCollection):
                return true
            default:
                return false
        }
    }
}
