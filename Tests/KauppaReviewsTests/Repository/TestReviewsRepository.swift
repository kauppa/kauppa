import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaReviewsModel
@testable import KauppaReviewsRepository

class TestReviewsRepository: XCTestCase {
    static var allTests: [(String, (TestReviewsRepository) -> () throws -> Void)] {
        return [
            ("Test review creation", testReviewCreation),
            ("Test review update", testReviewUpdate),
            ("Test store calls", testStoreCalls),
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

    func testReviewUpdate() {
        let store = TestStore()
        let repository = ReviewsRepository(withStore: store)
        var reviewData = ReviewData()
        let data = try! repository.createReview(data: reviewData)
        reviewData.comment = "foobar"
        let updatedData = try! repository.updateReviewData(id: data.id, data: reviewData)
        // We're just testing the function calls (extensive testing is done in service)
        XCTAssertEqual(updatedData.data.comment, "foobar")
        XCTAssertTrue(store.updateCalled)
    }

    func testStoreCalls() {
        let store = TestStore()
        let repository = ReviewsRepository(withStore: store)
        let reviewData = ReviewData()
        let data = try! repository.createReview(data: reviewData)
        repository.reviews = [:]        // clear the repository
        let _ = try? repository.getReview(forId: data.id)
        XCTAssertTrue(store.getCalled)  // this should've called the store
        store.getCalled = false         // now, pretend that we've never called the store
        let _ = try? repository.getReview(forId: data.id)
        // store shouldn't be called, because the data was recently fetched by the repository
        XCTAssertFalse(store.getCalled)
    }
}
