import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaGiftsModel
@testable import KauppaGiftsRepository

class TestGiftsRepository: XCTestCase {
    static var allTests: [(String, (TestGiftsRepository) -> () throws -> Void)] {
        return [
            ("Test creating gift card", testCardCreation),
            ("Test gift card update", testCardUpdate),
            ("Test store function calls", testStoreCalls),
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

    func testCardUpdate() {
        let store = TestStore()
        let repository = GiftsRepository(withStore: store)
        var data = GiftCardData()
        let card = try! repository.createCard(data: data)
        XCTAssertEqual(card.createdOn, card.updatedAt)

        data.note = "foobar"
        let updatedCard = try! repository.updateCardData(id: card.id, data: data)
        // We're just testing the function calls (extensive testing is done in service)
        XCTAssertEqual(updatedCard.data.note!, "foobar")
        XCTAssertTrue(updatedCard.createdOn != updatedCard.updatedAt)
        XCTAssertTrue(store.updateCalled)   // update called on store
    }

    func testStoreCalls() {
        let store = TestStore()
        let repository = GiftsRepository(withStore: store)
        let data = GiftCardData()
        let card = try! repository.createCard(data: data)
        repository.cards = [:]      // clear the repository
        let _ = try? repository.getCard(forId: card.id)
        XCTAssertTrue(store.getCalled)  // this should've called the store
        store.getCalled = false         // now, pretend that we never called the store
        let _ = try? repository.getCard(forId: card.id)
        // store shouldn't be called, because it was recently fetched by the repository
        XCTAssertFalse(store.getCalled)
    }
}
