import Foundation

import KauppaReviewsModel

public protocol ReviewsServiceCallable {
    /// Create a review comment for some entity with the given data.
    func createReview(withData data: ReviewData) throws -> Review
}
