import Foundation

/// Gifts service errors
public enum GiftsError: Error {
    case invalidGiftCardId
}

extension GiftsError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .invalidGiftCardId:
                return "No card associated with this UUID"
        }
    }
}

extension GiftsError {
    /// Check the equality of this result.
    public static func ==(lhs: GiftsError, rhs: GiftsError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidGiftCardId, .invalidGiftCardId):
                return true
            // default:
            //     return false
        }
    }
}
