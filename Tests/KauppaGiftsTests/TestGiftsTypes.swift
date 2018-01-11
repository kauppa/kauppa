import Foundation
import XCTest

import KauppaCore
@testable import KauppaGiftsModel

class TestGiftsTypes: XCTestCase {
    static var allTests: [(String, (TestGiftsTypes) -> () throws -> Void)] {
        return [
            ("Test gift card data", testGiftCardData),
            ("Test gift card deductions", testGiftCardDeductions),
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

    func testGiftCardDeductions() {
        var tests = [(GiftCardData, GiftsError)]()
        var data = GiftCardData()
        try! data.validate()
        tests.append((data, .noBalance))
        data.balance.value = 100.0
        data.balance.unit = .euro
        tests.append((data, .mismatchingCurrencies))
        data.disabledOn = Date()
        tests.append((data, .cardDisabled))
        data.expiresOn = Date()
        tests.append((data, .cardExpired))

        for (testCase, error) in tests {
            do {
                var card = testCase
                var price = UnitMeasurement(value: 120.0, unit: Currency.usd)
                try card.deductPrice(from: &price)
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! GiftsError, error)
            }
        }

        var price = UnitMeasurement(value: 120.0, unit: Currency.usd)
        data = GiftCardData()
        data.balance.value = 100.0
        try! data.deductPrice(from: &price)
        XCTAssertEqual(data.balance.value, 0)
        XCTAssertEqual(price.value, 20.0)
        data.balance.value = 50.0
        try! data.deductPrice(from: &price)
        XCTAssertEqual(data.balance.value, 30.0)
        XCTAssertEqual(price.value, 0)
    }
}
