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
    }

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
}
