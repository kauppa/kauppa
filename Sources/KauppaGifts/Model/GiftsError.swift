import Foundation

/// Gifts service errors
public enum GiftsError: Error {
    /// Thrown when the given UUID doesn't point to any card.
    case invalidGiftCardId
    /// Thrown when the given code doens't match any gift card.
    case invalidGiftCardCode
    /// By default, expiry dates for gift cards should be at least 1 day in the future.
    /// This occurs when they're not.
    case invalidExpiryDate
    /// If the (optional) code supplied for the card doesn't contain alphanumeric characters
    /// or has length not equal to 16, then we throw this error.
    case invalidCode
    case noBalance
    case cardDisabled
    case cardExpired
    case mismatchingCurrencies
}

extension GiftsError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .invalidGiftCardId:
                return "No card associated with this UUID"
            case .invalidGiftCardCode:
                return "No card found for the given code"
            case .invalidExpiryDate:
                return "Expiry date should be at least 1 day in the future"
            case .invalidCode:
                return "Code should be an alphanumeric string of 16 characters"
            case .mismatchingCurrencies:
                return "Card currency doesn't match with price currency"
            case .noBalance:
                return "Card doesn't have any balance"
            case .cardDisabled:
                return "Card has been disabled"
            case .cardExpired:
                return "Card has expired"
        }
    }
}

extension GiftsError {
    /// Check the equality of this result.
    public static func ==(lhs: GiftsError, rhs: GiftsError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidGiftCardId, .invalidGiftCardId),
                 (.invalidGiftCardCode, .invalidGiftCardCode),
                 (.invalidExpiryDate, .invalidExpiryDate),
                 (.invalidCode, .invalidCode),
                 (.mismatchingCurrencies, .mismatchingCurrencies),
                 (.noBalance, .noBalance),
                 (.cardDisabled, .cardDisabled),
                 (.cardExpired, .cardExpired):
                return true
            default:
                return false
        }
    }
}
