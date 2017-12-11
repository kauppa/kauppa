import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaReviewsModel
@testable import KauppaReviewsRepository
@testable import KauppaReviewsService

class TestReviewsService: XCTestCase {
    static var allTests: [(String, (TestReviewsService) -> () throws -> Void)] {
        return [
            ("Test review creation", testReviewCreation),
            ("Test invalid review comment", testInvalidComment),
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
        let service = ReviewsService(withRepository: repository)
        var reviewData = ReviewData()
        reviewData.comment = "You suck!"    // requires valid comment body
        let data = try! service.createReview(withData: reviewData)
        XCTAssertEqual(data.createdOn, data.updatedAt)
    }

    func testInvalidComment() {
        let store = TestStore()
        let repository = ReviewsRepository(withStore: store)
        let service = ReviewsService(withRepository: repository)
        let reviewData = ReviewData()
        do {
            let _ = try service.createReview(withData: reviewData)
            XCTFail()
        } catch let err {
            XCTAssertTrue(err as! ReviewsError == ReviewsError.invalidComment)
        }
    }
}
