import Foundation
import XCTest

import KauppaCore
@testable import KauppaGiftsModel

class TestGiftsTypes: XCTestCase {
    static var allTests: [(String, (TestGiftsTypes) -> () throws -> Void)] {
        return [
            ("Test gift card data", testGiftCardData),
        ]
    }

    func testGiftCardData() {
        var tests = [(GiftCardData, GiftsError)]()
        var data = GiftCardData()
        data.code = "abcde"     // less than 16 chars
        tests.append((data, GiftsError.invalidCode))
        data.code = "ABCDEFACECEFZANDALDA"  // greater than 16 chars
        tests.append((data, GiftsError.invalidCode))
        data.code = "ABCDEFGHIJKL@123"      // should be alphanumeric
        tests.append((data, GiftsError.invalidCode))
        data.code = nil
        data.expiresOn = Date()     // date should be at least 1-day higher
        tests.append((data, GiftsError.invalidExpiryDate))

        for (testCase, error) in tests {
            do {
                var testCase = testCase
                try testCase.validate()
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! GiftsError, error)
            }
        }
    }
}
