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
}
