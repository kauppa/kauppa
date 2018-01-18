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

    /// Available balance on this coupon.
    public var balance: UnitMeasurement<Currency> = UnitMeasurement(value: 0.0, unit: .usd)

    /// Date on which this coupon was disabled.
    public var disabledOn: Date? = nil

    public init() {}

    /// Validate this coupon data and modify as required.
    public mutating func validate() throws {
        if let code = code {
            if code.count != 16 || !code.isAlphaNumeric() {
                throw CouponError.invalidCode
            }

            self.code = code.uppercased()
        } else {
            self.code = String.randomAlphaNumeric(len: 16)
        }

        if let date = expiresOn {
            let interval = date.timeIntervalSinceNow / (60 * 60 * 24)
            if interval < 1 {   // should be at least one day
                throw CouponError.invalidExpiryDate
            }
        }
    }

    /// Deduct price from this coupon and the price supplied. It ensures coupon's
    /// validity before making any changes. If the coupon is valid, then it deducts
    /// the amount from the coupon and the given price. This only mutates the `balance`
    /// property of a `Coupon`
    public mutating func deductPrice(from price: inout UnitMeasurement<Currency>) throws {
        if let date = expiresOn {
            if date < Date() {
                throw CouponError.couponExpired
            }
        }

        if let date = disabledOn {
            if date < Date() {
                throw CouponError.couponDisabled
            }
        }

        if balance.value == 0 {
            throw CouponError.noBalance
        }

        if price.unit != balance.unit {
            throw CouponError.mismatchingCurrencies
        }

        if price.value > balance.value {
            price.value -= balance.value
            balance.value = 0.0
        } else {
            balance.value -= price.value
            price.value = 0.0
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
