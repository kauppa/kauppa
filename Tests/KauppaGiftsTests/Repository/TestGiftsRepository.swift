import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaGiftsModel
@testable import KauppaGiftsRepository

class TestGiftsRepository: XCTestCase {
    static var allTests: [(String, (TestGiftsRepository) -> () throws -> Void)] {
        return [
            ("Test creating gift card", testCardCreation),
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
        let data = GiftCardData()
        let card = try! repository.createCard(data: data)
        XCTAssertTrue(store.createCalled)   // store has been called for creation
        XCTAssertNotNil(repository.cards[card.id])  // repository has the card.
    }
}
