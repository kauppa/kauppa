import Foundation

@testable import KauppaReviewsModel
@testable import KauppaReviewsStore

public class TestStore: ReviewsStorable {
    public var reviews = [UUID: Review]()

    // Variables to indicate the count of function calls
    public var createCalled = false
    public var getCalled = false
    public var updateCalled = false

    public func createReview(data: Review) throws -> () {
        createCalled = true
        reviews[data.id] = data
        return ()
    }

    public func updateReview(reviewData: Review) throws -> () {
        updateCalled = true
        reviews[reviewData.id] = reviewData
        return ()
    }

    public func getReviews(forProduct id: UUID) throws -> [Review] {
        var matched = [Review]()
        for (_, review) in reviews {
            if review.data.productId == id {
                matched.append(review)
            }
        }

        return matched
    }

    public func getReview(id: UUID) throws -> Review {
        getCalled = true
        guard let review = reviews[id] else {
            throw ReviewsError.invalidReviewId
        }

        return review
    }
}
