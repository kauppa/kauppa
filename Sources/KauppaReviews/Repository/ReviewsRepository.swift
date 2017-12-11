import Foundation

import KauppaCore
import KauppaReviewsModel
import KauppaReviewsStore

/// Manages the retrieval and persistance of review data from store.
public class ReviewsRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var reviews = [UUID: Review]()
    var store: ReviewsStorable

    public init(withStore store: ReviewsStorable) {
        self.store = store
    }

    /// Create a review with data from the service.
    public func createReview(data: ReviewData) throws -> Review {
        let id = UUID()
        let date = Date()
        let review = Review(id: id, createdOn: date,
                            updatedAt: date, data: data)
        reviews[id] = review
        try store.createReview(data: review)
        return review
    }

    /// Get the review corresponding to an ID.
    public func getReview(forId id: UUID) throws -> Review {
        guard let review = reviews[id] else {
            let review = try store.getReview(id: id)
            reviews[id] = review
            return review
        }

        return review
    }

    /// Get all the reviews belonging to a product.
    public func getReviews(forProduct id: UUID) throws -> [Review] {
        // NOTE: We cannot query something like this efficiently unless we
        // change the underlying data structure of the repository.
        return try store.getReviews(forProduct: id)
    }

    /// Get a review's data corresponding to an ID.
    public func getReviewData(forId id: UUID) throws -> ReviewData {
        let review = try getReview(forId: id)
        return review.data
    }

    /// Update the review data for a given ID.
    public func updateReviewData(id: UUID, data: ReviewData) throws -> Review {
        var review = try getReview(forId: id)
        let date = Date()
        review.updatedAt = date
        review.data = data
        reviews[id] = review
        try store.updateReview(reviewData: review)
        return review
    }
}
