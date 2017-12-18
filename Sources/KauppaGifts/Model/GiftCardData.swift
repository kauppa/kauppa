import Foundation

import KauppaCore

/// Additional data for a gift card.
public struct GiftCardData: Mappable {
    /// Order in which this card was created (optional).
    public var orderId: UUID? = nil

    /// Once the card has been issued to a customer, this
    /// will have the account's ID.
    public var accountId: UUID? = nil

    /// Code for this gift card - should be an uppercase alphanumeric
    /// string of 16 chars.
    public var code: String? = nil

    /// Expiry date for this gift card (if any).
    public var expiresOn: Date? = nil

    /// Custom note for this card.
    public var note: String? = nil

    /// Available balance on this card.
    public var balance: UnitMeasurement<Currency> = UnitMeasurement(value: 0.0, unit: .usd)

    /// Date on which this card was disabled.
    public var disabledOn: Date? = nil

    public init() {}

    /// Validate this gift card data and modify as required.
    public mutating func validate() throws {
        if let code = code {
            if code.count != 16 || !code.isAlphaNumeric() {
                throw GiftsError.invalidCode
            }

            self.code = code.uppercased()
        } else {
            self.code = String.randomAlphaNumeric(len: 16)
        }

        if let date = expiresOn {
            let interval = date.timeIntervalSinceNow / (60 * 60 * 24)
            if interval < 1 {   // should be at least one day
                throw GiftsError.invalidExpiryDate
            }
        }
    }

    /// Since gift cards are an alternative mode of payment,
    /// the full code is shown only once, and only the last
    /// four characters are shown in the future.
    ///
    /// NOTE: This function is supposed to be called only before
    /// returning a service response. Don't ever call this code
    /// before mutating the repository.
    public mutating func hideCode() {
        self.code = String(repeating: "X", count: 12) + code!.suffix(4)
    }
}
