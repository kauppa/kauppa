import Foundation

/// Products service errors
public enum ProductsError: Error {
    case invalidProduct
}

extension ProductsError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .invalidProduct:
                return "No product found for the given UUID"
        }
    }
}
