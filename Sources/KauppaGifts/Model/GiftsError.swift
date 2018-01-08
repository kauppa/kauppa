import Foundation

/// Gifts service errors
public enum GiftsError: Error {
    /// Thrown when the given UUID doesn't point to any card.
    case invalidGiftCardId
    /// By default, expiry dates for gift cards should be at least 1 day in the future.
    /// This occurs when they're not.
    case invalidExpiryDate
    /// If the (optional) code supplied for the card doesn't contain alphanumeric characters
    /// or has length not equal to 16, then we throw this error.
    case invalidCode
}

extension GiftsError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .invalidGiftCardId:
                return "No card associated with this UUID"
            case .invalidExpiryDate:
                return "Expiry date should be at least 1 day in the future"
            case .invalidCode:
                return "Code should be an alphanumeric string of 16 characters"
        }
    }
}

extension GiftsError {
    /// Check the equality of this result.
    public static func ==(lhs: GiftsError, rhs: GiftsError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidGiftCardId, .invalidGiftCardId),
                 (.invalidExpiryDate, .invalidExpiryDate),
                 (.invalidCode, .invalidCode):
                return true
            default:
                return false
        }
    }
}
