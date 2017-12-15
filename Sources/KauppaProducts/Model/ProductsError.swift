import Foundation

/// Products service errors
public enum ProductsError: Error {
    case invalidTitle
    case invalidSubtitle
    case invalidDescription
    case invalidColor
    case invalidProduct
    case invalidCollection
}

extension ProductsError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .invalidTitle:
                return "Invalid title in product data"
            case .invalidSubtitle:
                return "Invalid subtitle in product data"
            case .invalidDescription:
                return "Invalid description in product data"
            case .invalidColor:
                return "Invalid hex value for color"
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
                 (.invalidCollection, .invalidCollection),
                 (.invalidTitle, .invalidTitle),
                 (.invalidSubtitle, .invalidSubtitle),
                 (.invalidDescription, .invalidDescription),
                 (.invalidColor, .invalidColor):
                return true
            default:
                return false
        }
    }
}
