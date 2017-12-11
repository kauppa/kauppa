import Foundation

/// Reviews service errors
public enum ReviewsError: Error {
    case invalidAccount
    case invalidReviewId
    case invalidComment
}

extension ReviewsError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .invalidAccount:
                return "No account found for the given UUID"
            case .invalidReviewId:
                return "No reviews associated with this UUID"
            case .invalidComment:
                return "Invalid comment body"
        }
    }
}

extension ReviewsError {
    /// Check the equality of this result.
    public static func ==(lhs: ReviewsError, rhs: ReviewsError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidAccount, .invalidAccount),
                 (.invalidReviewId, .invalidReviewId),
                 (.invalidComment, .invalidComment):
                return true
            default:
                return false
        }
    }
}
