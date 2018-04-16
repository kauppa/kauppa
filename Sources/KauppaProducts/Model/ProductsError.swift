import Foundation

/// Products service errors
public enum ProductsError: Error {
    /* Products related errors */
    case invalidTitle
    case invalidSubtitle
    case invalidDescription
    case invalidColor

    /* Collection-related errors */
    case invalidCollectionName
    case invalidCollectionDescription
    /// No product found for the given UUID.
    case invalidProduct
    /// No product collection found for the given UUID.
    case invalidCollection

    /* Custom Attribute related errors */
    /// No attribute found for the given UUID.
    case invalidAttribute
    case invalidAttributeName
    case invalidAttributeValue
    case attributeRequiresType
    case attributeRequiresUnit
    case invalidAttributeUnit
    case notEnoughVariants
    case invalidEnumVariant
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
            case .notEnoughVariants:
                return "At least two variants are required for enum type"
            case .invalidEnumVariant:
                return "Invalid variant found for enum"
        }
    }
}

extension ProductsError {
    /// Check the equality of this result.
    public static func ==(lhs: ProductsError, rhs: ProductsError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidTitle, .invalidTitle),
                 (.invalidSubtitle, .invalidSubtitle),
                 (.invalidDescription, .invalidDescription),
                 (.invalidColor, .invalidColor),

                 (.invalidProduct, .invalidProduct),
                 (.invalidCollection, .invalidCollection),
                 (.invalidCollectionName, .invalidCollectionName),
                 (.invalidCollectionDescription, .invalidCollectionDescription),

                 (.invalidAttribute, .invalidAttribute),
                 (.invalidAttributeName, .invalidAttributeName),
                 (.invalidAttributeValue, .invalidAttributeValue),
                 (.attributeRequiresUnit, .attributeRequiresUnit),
                 (.invalidAttributeUnit, .invalidAttributeUnit),
                 (.attributeRequiresType, .attributeRequiresType),
                 (.notEnoughVariants, .notEnoughVariants),
                 (.invalidEnumVariant, .invalidEnumVariant):
                return true
            default:
                return false
        }
    }
}
