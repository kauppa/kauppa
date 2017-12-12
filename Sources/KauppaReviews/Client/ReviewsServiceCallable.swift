import Foundation

import KauppaReviewsModel

public protocol ReviewsServiceCallable {
    /// Create a review comment for some entity with the given data.
    func createReview(withData data: ReviewData) throws -> Review

    /// Get reviews for a product.
    func getReviews(forProduct: UUID) throws -> [Review]

    /// Update the review associated with an ID.
    func updateReview(id: UUID, data: ReviewPatch) throws -> Review
}
