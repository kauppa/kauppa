import Foundation

/// Products service errors
public enum ProductsError: Error {
    case invalidTitle
    case invalidSubtitle
    case invalidDescription
    case invalidColor
    case invalidCollectionName
    case invalidCollectionDescription
    /// No product found for the given UUID.
    case invalidProduct
    /// No product collection found for the given UUID.
    case invalidCollection
    /// No product found for the given UUID.
    case invalidAttribute
    case invalidAttributeName
    case invalidAttributeValue
    case attributeRequiresType
    case attributeRequiresUnit
    case invalidAttributeUnit
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
            case .invalidCollectionName:
                return "Invalid name for collection"
            case .invalidCollectionDescription:
                return "Invalid description for collection"
            case .invalidProduct:
                return "No product found for the given UUID"
            case .invalidCollection:
                return "No collection found for the given UUID"
            case .invalidAttribute:
                return "No attribute found for the given UUID"
            case .invalidAttributeName:
                return "Invalid name for the given attribute"
            case .invalidAttributeValue:
                return "Invalid value for the given attribute"
            case .attributeRequiresType:
                return "Type is required for the attribute"
            case .attributeRequiresUnit:
                return "Unit is required for the attribute"
            case .invalidAttributeUnit:
                return "Invalid unit for the given attribute"
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
                 (.invalidCollectionName, .invalidCollectionName),
                 (.invalidCollectionDescription, .invalidCollectionDescription),
                 (.invalidColor, .invalidColor),
                 (.invalidAttribute, .invalidAttribute),
                 (.invalidAttributeName, .invalidAttributeName),
                 (.invalidAttributeValue, .invalidAttributeValue),
                 (.attributeRequiresUnit, .attributeRequiresUnit),
                 (.invalidAttributeUnit, .invalidAttributeUnit),
                 (.attributeRequiresType, .attributeRequiresType):
                return true
            default:
                return false
        }
    }
}
