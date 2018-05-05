import Foundation
import XCTest

import KauppaCore
@testable import KauppaCouponModel

class TestCouponTypes: XCTestCase {
    static var allTests: [(String, (TestCouponTypes) -> () throws -> Void)] {
        return [
            ("Test coupon data", testCouponData),
            ("Test coupon deductions", testCouponDeductions),
        ]
    }

    func testCouponData() {
        var tests = [(CouponData, ServiceError)]()
        var data = CouponData()
        data.code = "abcde"     // less than 16 chars
        tests.append((data, ServiceError.invalidCouponCode))
        data.code = "ABCDEFACECEFZANDALDA"  // greater than 16 chars
        tests.append((data, ServiceError.invalidCouponCode))
        data.code = "ABCDEFGHIJKL@123"      // should be alphanumeric
        tests.append((data, ServiceError.invalidCouponCode))
        data.code = nil
        data.expiresOn = Date()     // date should be at least 1-day higher
        tests.append((data, ServiceError.invalidCouponExpiryDate))

        for (testCase, error) in tests {
            do {
                var testCase = testCase
                try testCase.validate()
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }

    func testCouponDeductions() {
        var tests = [(CouponData, ServiceError)]()
        var data = CouponData()
        try! data.validate()
        tests.append((data, .noBalance))
        data.balance = Price(100)
        data.currency = .euro
        tests.append((data, .ambiguousCurrencies))
        data.disabledOn = Date()
        tests.append((data, .couponDisabled))
        data.expiresOn = Date()
        tests.append((data, .couponExpired))

        for (testCase, error) in tests {
            do {
                var coupon = testCase
                var price = Price(120)
                try coupon.deductPrice(from: &price, with: .usd)
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }

        var price = Price(120.0)
        data = CouponData()
        data.balance = Price(100)
        try! data.deductPrice(from: &price, with: .usd)
        XCTAssertEqual(data.balance.value, 0)
        XCTAssertEqual(price.value, 20.0)
        data.balance = Price(50)
        try! data.deductPrice(from: &price, with: .usd)
        XCTAssertEqual(data.balance.value, 30.0)
        XCTAssertEqual(price.value, 0)
    }
}
