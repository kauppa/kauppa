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

    // Test creating a gift card in the repository. Validation happens only in the service end.
    // Here, we only check for proper calls to store and caching in repository itself.
    func testCardCreation() {
        let store = TestStore()
        let repository = GiftsRepository(withStore: store)
        var data = GiftCardData()
        data.code = "foobar"    // invalid code (but, this is checked by service)
        let card = try! repository.createCard(data: data)
        XCTAssertTrue(store.createCalled)   // store has been called for creation
        XCTAssertNotNil(repository.cards[card.id])  // repository has the card.
        XCTAssertNotNil(repository.codes[card.data.code!])  // repository also caches code
    }

    // Updating the card in repository should update the cache and the store
    func testCardUpdate() {
        let store = TestStore()
        let repository = GiftsRepository(withStore: store)
        var data = GiftCardData()
        data.code = "foobar"
        let card = try! repository.createCard(data: data)
        XCTAssertEqual(card.createdOn, card.updatedAt)

        data.note = "foobar"
        let updatedCard = try! repository.updateCardData(id: card.id, data: data)
        // We're just testing the function calls (extensive testing is done in service)
        XCTAssertEqual(updatedCard.data.note!, "foobar")
        XCTAssertTrue(updatedCard.createdOn != updatedCard.updatedAt)
        XCTAssertTrue(store.updateCalled)   // update called on store
    }

    // Test the repository for proper store calls. If the item doesn't exist in the cache, then
    // it should get from the store and cache it. Re-getting the item shouldn't call the store.
    func testStoreCalls() {
        let store = TestStore()
        let repository = GiftsRepository(withStore: store)
        var data = GiftCardData()
        data.code = "foobar"
        let card = try! repository.createCard(data: data)
        repository.cards = [:]      // clear the cards
        let _ = try? repository.getCard(forId: card.id)
        XCTAssertTrue(store.getCalled)  // this should've called the store
        repository.codes = [:]      // clear the codes
        let _ = try? repository.getCard(forCode: card.data.code!)
        XCTAssertTrue(store.codeGetCalled)  // this should've called again for code
        store.getCalled = false         // now, pretend that we never called the store
        let _ = try? repository.getCard(forId: card.id)
        // store shouldn't be called, because it was recently fetched by the repository
        XCTAssertFalse(store.getCalled)
    }
}
