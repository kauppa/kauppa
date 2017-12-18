import Foundation

import KauppaCore

/// Additional data for a gift card.
public struct GiftCardData: Mappable {
    /// Order in which this card was created (optional).
    public var orderId: UUID? = nil

    /// Once the card has been issued to a customer, this
    /// will have the account's ID.
    public var accountId: UUID? = nil

    /// Code for this gift card. Should be an uppercase alphanumeric
    /// string of 16 chars.
    public var code: String? = nil

    /// Expiry date for this gift card (if any).
    public var expiresOn: Date? = nil

    /// Custom note for this card.
    public var note: String? = nil

    /// Initial worth of this gift card.
    public var initialValue: UnitMeasurement<Currency> = UnitMeasurement(value: 0.0, unit: .usd)

    /// Available balance on this card.
    public var balance: UnitMeasurement<Currency> = UnitMeasurement(value: 0.0, unit: .usd)

    public init() {}
}
