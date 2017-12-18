import Foundation
import XCTest

import KauppaCore
@testable import KauppaGiftsModel
@testable import KauppaGiftsRepository
@testable import KauppaGiftsService

class TestGiftsService: XCTestCase {
    static var allTests: [(String, (TestGiftsService) -> () throws -> Void)] {
        return [
            ("Test card creation", testCardCreation),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCardCreation() {
        let store = TestStore()
        let repository = GiftsRepository(withStore: store)
        let service = GiftsService(withRepository: repository)
        let data = GiftCardData()

        let card = try! service.createCard(withData: data)
        // Creation and updated timestamps should be equal.
        XCTAssertEqual(card.createdOn, card.updatedAt)
    }
}
