import Foundation

import KauppaCore
import KauppaReviewsClient
import KauppaReviewsModel
import KauppaReviewsRepository

/// Public API for review comments on different entities.
public class ReviewsService {
    let repository: ReviewsRepository

    /// Initializes a new `ReviewsService` instance with a
    /// repository.
    public init(withRepository repository: ReviewsRepository) {
        self.repository = repository
    }
}

extension ReviewsService: ReviewsServiceCallable {
    public func createReview(withData data: ReviewData) throws -> Review {
        return try repository.createReview(data: data)
    }
}
