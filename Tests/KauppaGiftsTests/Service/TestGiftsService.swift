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
            ("Test card creation with code", testCardCreationWithCode),
            ("Test card creation with expiry", testCardCreationWithExpiry),
            ("Test card update", testCardUpdate),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Test service card creation. If the code is not specified, then a random 16-char
    // alphanumeric code is assigned to the card.
    func testCardCreation() {
        let store = TestStore()
        let repository = GiftsRepository(withStore: store)
        let service = GiftsService(withRepository: repository)
        var data = GiftCardData()
        data.balance.unit = .rupee
        data.balance.value = 100.0

        XCTAssertNil(data.code)
        let card = try! service.createCard(withData: data)
        // Creation and updated timestamps should be equal.
        XCTAssertEqual(card.createdOn, card.updatedAt)
        XCTAssertEqual(card.data.code!.count, 16)   // 16-char code
        XCTAssertTrue(card.data.code!.isAlphaNumeric())     // random alphanumeric code
    }

    // Test card creation with code. If the card code is not 16-char, or if it's not
    // alphanumeric, then it'll be rejected.
    func testCardCreationWithCode() {
        let store = TestStore()
        let repository = GiftsRepository(withStore: store)
        let service = GiftsService(withRepository: repository)
        var data = GiftCardData()
        data.code = "ef23f23qc"
        do {
            let _ = try service.createCard(withData: data)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! GiftsError, GiftsError.invalidCode)
        }

        data.code = "ABCDEFGHIJKLMNOP"
        let card = try! service.createCard(withData: data)
        XCTAssertEqual(card.data.code!, "ABCDEFGHIJKLMNOP")
        let _ = try! service.getCard(forCode: data.code!)
        let _ = try! service.getCard(id: card.id)
    }

    // Test for service checking expiry dates for gift cards, which should be at least
    // 1 day from the day of creation.
    func testCardCreationWithExpiry() {
        let store = TestStore()
        let repository = GiftsRepository(withStore: store)
        let service = GiftsService(withRepository: repository)
        var data = GiftCardData()
        data.expiresOn = Date()

        do {
            let _ = try service.createCard(withData: data)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! GiftsError, GiftsError.invalidExpiryDate)
        }

        data.expiresOn = Date(timeIntervalSinceNow: 87000)
        let card = try! service.createCard(withData: data)
        XCTAssertNotNil(card.data.expiresOn)
    }

    // Test updating gift card. We can updating everything other than the card's code.
    // Future card objects will have hidden the code. Only creation should show the code.
    func testCardUpdate() {
        let store = TestStore()
        let repository = GiftsRepository(withStore: store)
        let service = GiftsService(withRepository: repository)
        let data = GiftCardData()
        let card = try! service.createCard(withData: data)
        let code = card.data.code!

        var patch = GiftCardPatch()     // test valid patch
        patch.note = "foobar"
        patch.balance = UnitMeasurement(value: 100.0, unit: .usd)
        let currentDate = Date()
        patch.disable = true
        patch.expiresOn = Date(timeIntervalSinceNow: 87000)

        let updatedCard = try! service.updateCard(id: card.id, data: patch)
        XCTAssertTrue(updatedCard.createdOn != updatedCard.updatedAt)
        XCTAssertEqual(updatedCard.data.note!, "foobar")
        XCTAssertEqual(updatedCard.data.balance.value, 100.0)
        XCTAssertTrue(updatedCard.data.disabledOn! > currentDate)
        XCTAssertEqual(updatedCard.data.expiresOn!, patch.expiresOn!)
        // Check that only the last 4 digits are shown in update.
        XCTAssertTrue(updatedCard.data.code!.starts(with: "XXXXXXXXXXXX"))
        XCTAssertEqual(updatedCard.data.code!.suffix(4), code.suffix(4))

        patch.expiresOn = Date()
        do {    // data is validated for update
            let _ = try service.updateCard(id: card.id, data: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! GiftsError, GiftsError.invalidExpiryDate)
        }
    }
}
