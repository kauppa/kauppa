import Foundation

/// Coupon service errors
public enum CouponError: Error {
    /// Thrown when the given UUID doesn't point to any coupon.
    case invalidCouponId
    /// Thrown when the given code doens't match any coupon.
    case invalidCouponCode
    /// By default, expiry dates for coupons should be at least 1 day in the future.
    /// This occurs when they're not.
    case invalidExpiryDate
    /// If the (optional) code supplied for the coupon doesn't contain alphanumeric characters
    /// or has length not equal to 16, then we throw this error.
    case invalidCode
    case noBalance
    case couponDisabled
    case couponExpired
    case mismatchingCurrencies
}

extension CouponError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .invalidCouponId:
                return "No coupon associated with this UUID"
            case .invalidCouponCode:
                return "No coupon found for the given code"
            case .invalidExpiryDate:
                return "Expiry date should be at least 1 day in the future"
            case .invalidCode:
                return "Code should be an alphanumeric string of 16 characters"
            case .mismatchingCurrencies:
                return "Coupon currency doesn't match with price currency"
            case .noBalance:
                return "Coupon doesn't have any balance"
            case .couponDisabled:
                return "Coupon has been disabled"
            case .couponExpired:
                return "Coupon has expired"
        }
    }
}

extension CouponError {
    /// Check the equality of this result.
    public static func ==(lhs: CouponError, rhs: CouponError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidCouponId, .invalidCouponId),
                 (.invalidCouponCode, .invalidCouponCode),
                 (.invalidExpiryDate, .invalidExpiryDate),
                 (.invalidCode, .invalidCode),
                 (.mismatchingCurrencies, .mismatchingCurrencies),
                 (.noBalance, .noBalance),
                 (.couponDisabled, .couponDisabled),
                 (.couponExpired, .couponExpired):
                return true
            default:
                return false
        }
    }
}
