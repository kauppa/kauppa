/// Service error used throughout Kauppa services. The errors have their own error codes.
public enum ServiceError: UInt16, Error {
    /* Generic errors */
    case clientHTTPData
    case invalidRegex
    case missingURLParameter
    case jsonParse
    case jsonErrorParse
    case jsonSerialization
    case unknownError

    /* Accounts service errors */

    // Accounts-related errors
    case accountExists
    case accountEmailRequired
    case invalidAccountEmail
    case invalidAccountId
    case invalidAccountName
    case invalidAccountPhone

    // Address-related errors
    case invalidAddressName
    case invalidAddressLineData
    case invalidAddressCity
    case invalidAddressProvince
    case invalidAddressCountry
    case invalidAddressCode
    case invalidAddressLabel

    /* Cart service errors */

    case cartUnavailable
    case noItemsInCart
    case noItemsToProcess
    case productUnavailable
    case ambiguousCurrencies
    case invalidItemId
    case invalidAddress

    /* Coupon service errors */

    case invalidCouponId
    case invalidCouponCode
    case invalidCouponExpiryDate
    case noBalance
    case couponDisabled
    case couponExpired

    /* Products service errors */

    // Products-related errors
    case missingProductId
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

    // Category-related errors
    case invalidCategoryId
    case invalidCategoryName

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
