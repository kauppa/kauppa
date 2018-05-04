import Foundation

import KauppaCore

/// Additional data for a coupon.
public struct CouponData: Mappable {
    /// Order in which this coupon was created (optional).
    public var orderId: UUID? = nil

    /// Once the coupon has been issued to a customer, this
    /// will have the account's ID.
    public var accountId: UUID? = nil

    /// Code for this coupon - uppercase alphanumeric string of 16 chars.
    public var code: String? = nil

    /// Expiry date for this coupon (if any).
    public var expiresOn: Date? = nil

    /// Custom note for this coupon.
    public var note: String? = nil

    /// Currency of this coupon.
    public var currency: Currency

    /// Available balance on this coupon.
    public var balance: Price

    /// Date on which this coupon was disabled.
    public var disabledOn: Date? = nil

    /// Validate this coupon data and modify as required.
    ///
    /// - Throws: `ServiceError` if an error was encountered.
    public mutating func validate() throws {
        if let code = code {
            if code.count != 16 || !code.isAlphaNumeric() {
                throw ServiceError.invalidCouponCode
            }

            self.code = code.uppercased()
        } else {
            self.code = String.randomAlphaNumeric(ofLength: 16)
        }

        if let date = expiresOn {
            let interval = date.timeIntervalSinceNow / (60 * 60 * 24)
            if interval < 1 {   // should be at least one day
                throw ServiceError.invalidCouponExpiryDate
            }
        }
    }

    /// Deduct price from this coupon and the price supplied. It ensures coupon's
    /// validity before making any changes. If the coupon is valid, then it deducts
    /// the amount from the coupon and the given price. This only mutates the `balance`
    /// property of a `Coupon`
    ///
    /// - Parameters:
    ///   - from: The price to which the change should be made.
    ///   - with: The currency used in transaction.
    /// - Throws: `ServiceError` if there was an error in changing the price.
    public mutating func deductPrice(from price: inout Price, with currency: Currency) throws {
        if let date = expiresOn {
            if date < Date() {
                throw ServiceError.couponExpired
            }
        }

        if let date = disabledOn {
            if date < Date() {
                throw ServiceError.couponDisabled
            }
        }

        if balance.value == 0 {
            throw ServiceError.noBalance
        }

        if currency != self.currency {
            throw ServiceError.ambiguousCurrencies
        }

        if price > balance {
            price -= balance
            balance = Price()
        } else {
            balance -= price
            price = Price()
        }
    }

    /// Since coupons are an alternative mode of payment,
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
