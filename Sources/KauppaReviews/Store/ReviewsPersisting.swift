import Foundation

import KauppaCore
import KauppaReviewsModel

/// Methods that mutate the underlying store with information.
public protocol ReviewsPersisting: Persisting {
    /// Create a review with data from the repository.
    func createReview(data: Review) throws -> ()
}
