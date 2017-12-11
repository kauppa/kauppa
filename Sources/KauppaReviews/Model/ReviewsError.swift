import Foundation

/// Reviews service errors
public enum ReviewsError: Error {
    case invalidReviewId
    case invalidComment
}

extension ReviewsError: LocalizedError {
    var localizedDescription: String {
        switch self {
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
            case (.invalidReviewId, .invalidReviewId),
                 (.invalidComment, .invalidComment):
                return true
            default:
                return false
        }
    }
}
