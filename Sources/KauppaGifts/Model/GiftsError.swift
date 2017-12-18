import Foundation

/// Gifts service errors
public enum GiftsError: Error {
    case invalidGiftCardId
    case invalidExpiryDate
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
