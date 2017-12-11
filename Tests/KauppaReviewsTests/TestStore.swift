import Foundation

@testable import KauppaReviewsModel
@testable import KauppaReviewsStore

public class TestStore: ReviewsStorable {
    public var reviews = [UUID: Review]()

    // Variables to indicate the count of function calls
    public var createCalled = false

    public func createReview(data: Review) throws -> () {
        createCalled = true
        reviews[data.id] = data
        return ()
    }
}
