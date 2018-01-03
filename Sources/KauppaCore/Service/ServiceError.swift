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
    /// One or more products are unavailable in the inventory.
    case productUnavailable
    /// One or more items in the data have prices with mismatching currencies.
    case ambiguousCurrencies
    /// Given item is not found in data.
    case invalidItemId
    case invalidAddress

    /* Coupon service errors */

    case invalidCouponId
    case invalidCouponCode
    case invalidCouponExpiryDate
    case noBalance
    case couponDisabled
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
