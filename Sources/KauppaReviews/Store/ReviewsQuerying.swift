import Foundation

import KauppaCore
import KauppaReviewsModel

/// Methods that fetch data from the underlying store.
public protocol ReviewsQuerying: Querying {
    /// Get the review corresponding to an ID.
    func getReview(id: UUID) throws -> Review

    /// Get the reviews belonging to a product.
    // FIXME: Support pagination
    func getReviews(forProduct id: UUID) throws -> [Review]
}
