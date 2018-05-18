/// Service error used throughout Kauppa services. The errors have their own error codes.
public enum ServiceError: UInt16, Error {
    /* Generic errors */

    /// The JSON data parsed from the request body is invalid.
    case clientHTTPData
    /// The given regular expression is invalid.
    case invalidRegex
    /// The URL for the route has a parameter, but its value has not been passed to the client.
    case missingURLParameter
    /// Error parsing JSON from the request/response body.
    case jsonParse
    /// The response is an error. But, we're unable to parse the error.
    case jsonErrorParse
    /// Error serailizing the JSON object into request/response body.
    case jsonSerialization
    /// Some unhandled/unknown error has propagated from within the service.
    case unknownError

    /* Database errors */

    /// Invalid URL for this database.
    case invalidDatabaseURL
    /// Error connecting to the database.
    case connectionError
    /// Execute method is unimplemented for this database.
    case executeUnimplemented
    /// Query method is unimplemented for this database.
    case queryUnimplemented

    /* Accounts service errors */

    // Accounts-related errors
    /// Account cannot be created for the given mail, because it already exists.
    case accountExists
    /// An email is required for creating an account.
    case accountEmailRequired
    /// The given email for the account is invalid.
    case invalidAccountEmail
    /// No account associated with the given UUID.
    case invalidAccountId
    /// Invalid name given for the account.
    case invalidAccountName
    /// Invalid phone number given for the account.
    case invalidAccountPhone

    // Address-related errors
    /// Address is required for billing/shipping, but it's invalid or not provided.
    case invalidAddress
    /// Invalid name for the given address.
    case invalidAddressName
    /// Invalid address line data.
    case invalidAddressLineData
    /// Invalid city for this address.
    case invalidAddressCity
    /// Invalid state/province name for this address.
    case invalidAddressProvince
    /// Invalid country name for this address.
    case invalidAddressCountry
    /// Invalid PIN/ZIP code for this address.
    case invalidAddressCode
    /// Invalid label for this address.
    case invalidAddressLabel

    /* Cart service errors */

    /// Cart is unavailable for the given ID. Generally, all user accounts are associated
    /// with a cart, and `invalidAccountId` is thrown when the accounts service is queried
    /// with an invalid ID. So, there's no reason for this error to be propagated out of
    /// the service.
    case cartUnavailable
    /// Action cannot be carried out because it demands the cart to be non-empty.
    case noItemsInCart
    /// One or more products are unavailable in the inventory.
    case productUnavailable
    /// Checkout data missing for placing order.
    case invalidCheckoutData

    /* Coupon service errors */

    /// No coupon found for the given UUID.
    case invalidCouponId
    /// No coupon found for the given alphanumeric code.
    case invalidCouponCode
    /// Invalid expiry date for the coupon.
    case invalidCouponExpiryDate
    /// No balance in the coupon for deducting price.
    case noBalance
    /// Coupon has been disabled and hence it cannot be used.
    case couponDisabled
    /// Coupon has expired and hence it cannot be used.
    case couponExpired

    /* Orders service errors */

    /// No order found for the given UUID
    case invalidOrderId
    /// This action requires the account to be verified, but it's not been verified yet.
    case unverifiedAccount
    /// Some actions can happen only after payment, and the payment hasn't been received
    /// for this order yet.
    case paymentNotReceived
    /// Action cannot be carried out because this order has been cancelled.
    case cancelledOrder
    /// This order has already been refunded. Occurs when we try to refund again.
    case refundedOrder
    /// Reason invalid (or not given) for refunding
    case invalidRefundReason
    /// This action requires the item to be fulfilled, but it's not been fulfilled yet.
    case unfulfilledItem
    /// Shipped quantity seems to be higher than actual quantity that was supposed to be delivered.
    case invalidDeliveryQuantity
    /// Requested refund quantity is higher than the refundable quantity for this item.
    case invalidRefundQuantity
    /// Requested return quantity is higher than the fulfilled items in this unit.
    case invalidReturnQuantity
    /// Items picked seems to be higher than the items scheduled for pickup.
    case invalidPickupQuantity

    /* Products service errors */

    // Products-related errors
    /// No product found for the given UUID.
    case invalidProductId
    /// Invalid title for product.
    case invalidProductTitle
    /// Invalid subtitle for product.
    case invalidProductSubtitle
    /// Invalid description for product.
    case invalidProductDescription
    /// Invalid color supplied for product.
    case invalidProductColor

    // Collection-related errors
    /// No collection found for the given UUID.
    case invalidCollectionId
    /// Invalid name for the collection.
    case invalidCollectionName
    /// Invalid description for the collection.
    case invalidCollectionDescription

    // Custom attribute related errors
    /// No attribute found for the given UUID.
    case invalidAttributeId
    /// Invalid name for the attribute.
    case invalidAttributeName
    /// Invalid value for the attribute's type.
    case invalidAttributeValue
    /// Attribute requires a type during definition.
    case attributeRequiresType
    /// Attribute value requires an unit for its type.
    case attributeRequiresUnit
    /// Invalid unit for the given attribute value.
    case invalidAttributeUnit
    /// Enums should have at least two variants.
    case notEnoughVariants
    /// The given variant doesn't belong to that enum.
    case invalidEnumVariant

    // Category-related errors
    /// No category found for the given UUID.
    case invalidCategoryId
    /// No category found for the given name.
    case invalidCategoryName

    /* Shipments service errors */

    /// No shipment found for the given UUID
    case invalidShipmentId
        /// This action requires the shipment to be in 'pickup' state, but it's not.
    case notScheduledForPickup
    /// This action requires the shipment to be in 'shipping' state, but it's not.
    case notQueuedForShipping
    /// This action requires the shipment to be in 'shipped' state, but it's not.
    case notBeingShipped

    /* Tax service errors */

    /// Occurs when the given tax rate is invalid.
    case invalidTaxRate
    /// No country found for the specified UUID.
    case invalidCountryId
    /// No region found for the specified UUID.
    case invalidRegionId
    /// Occurs when the tax rate for a given category is invalid.
    case invalidCategoryTaxRate
    /// Invalid name for country.
    case invalidCountryName
    /// Invalid name for region.
    case invalidRegionName
    /// Given country doesn't exist in store.
    case noMatchingCountry
    /// Given region not found in store.
    case noMatchingRegion

    /* Generic item-related errors */

    /// An action requires at least one item in the list, but none exist.
    /// This could happen in cart, orders or shipments.
    case noItemsToProcess
    /// One or more items in the data have prices with mismatching currencies.
    case ambiguousCurrencies
    /// Given item is not found in data.
    case invalidItemId
}

extension ServiceError {
    public static func ==(lhs: ServiceError, rhs: ServiceError) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
