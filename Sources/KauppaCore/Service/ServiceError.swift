public enum ServiceError: UInt16, Error {
    /* Generic errors */
    case clientHTTPData

    case jsonParse
    case jsonErrorParse
    case jsonSerialization
    case unknownError

    /* Products service errors */

    // Products-related errors
    case invalidProductId
    case invalidProductTitle
    case invalidProductSubtitle
    case invalidProductDescription
    case invalidProductColor

    // Collection-related errors
    case invalidCollectionId
    case invalidCollectionName
    case invalidCollectionDescription
    case invalidCollectionProduct

    // Custom attribute related errors
    case invalidAttributeId
    case invalidAttributeName
    case invalidAttributeValue
    case attributeRequiresType
    case attributeRequiresUnit
    case invalidAttributeUnit
    case notEnoughVariants
    case invalidEnumVariant

    /* Tax service errors */

    case invalidTaxRate
    case invalidCountryId
    case invalidRegionId
    case invalidCategoryTaxRate
    case invalidCountryName
    case invalidRegionName
    case noMatchingCountry
    case noMatchingRegion
}

extension ServiceError {
    public static func ==(lhs: ServiceError, rhs: ServiceError) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
