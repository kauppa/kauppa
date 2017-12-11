import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaReviewsModel
@testable import KauppaReviewsRepository

class TestReviewsRepository: XCTestCase {
    static var allTests: [(String, (TestReviewsRepository) -> () throws -> Void)] {
        return [
            ("Test review creation", testReviewCreation),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testReviewCreation() {
        let store = TestStore()
        let repository = ReviewsRepository(withStore: store)
        let reviewData = ReviewData()
        // These two timestamps should be the same in creation
        let data = try! repository.createReview(data: reviewData)
        XCTAssertEqual(data.createdOn, data.updatedAt)
        XCTAssertTrue(store.createCalled)       // store has been called for creation
        XCTAssertNotNil(repository.reviews[data.id])    // repository has the review
    }
}
