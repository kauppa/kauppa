import Foundation
import XCTest

import KauppaCore
@testable import KauppaCouponModel
@testable import KauppaCouponRepository
@testable import KauppaCouponService

class TestCouponService: XCTestCase {
    static var allTests: [(String, (TestCouponService) -> () throws -> Void)] {
        return [
            ("Test coupon creation", testCouponCreation),
            ("Test coupon creation with code", testCouponCreationWithCode),
            ("Test coupon creation with expiry", testCouponCreationWithExpiry),
            ("Test coupon update", testCouponUpdate),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Test service coupon creation. If the code is not specified, then a random 16-char
    // alphanumeric code is assigned to the coupon.
    func testCouponCreation() {
        let store = TestStore()
        let repository = CouponRepository(with: store)
        let service = CouponService(with: repository)
        var data = CouponData()
        data.balance.unit = .rupee
        data.balance.value = 100.0

        XCTAssertNil(data.code)
        let coupon = try! service.createCoupon(with: data)
        // Creation and updated timestamps should be equal.
        XCTAssertEqual(coupon.createdOn, coupon.updatedAt)
        XCTAssertEqual(coupon.data.code!.count, 16)   // 16-char code
        XCTAssertTrue(coupon.data.code!.isAlphaNumeric())     // random alphanumeric code
    }

    // Test coupon creation with code. If the coupon code is not 16-char, or if it's not
    // alphanumeric, then it'll be rejected.
    func testCouponCreationWithCode() {
        let store = TestStore()
        let repository = CouponRepository(with: store)
        let service = CouponService(with: repository)
        var data = CouponData()
        data.code = "ef23f23qc"
        do {
            let _ = try service.createCoupon(with: data)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! CouponError, CouponError.invalidCode)
        }

        data.code = "ABCDEFGHIJKLMNOP"
        let coupon = try! service.createCoupon(with: data)
        XCTAssertEqual(coupon.data.code!, "ABCDEFGHIJKLMNOP")
        let _ = try! service.getCoupon(for: data.code!)
        let _ = try! service.getCoupon(for: coupon.id)
    }

    // Test for service checking expiry dates for coupons, which should be at least
    // 1 day from the day of creation.
    func testCouponCreationWithExpiry() {
        let store = TestStore()
        let repository = CouponRepository(with: store)
        let service = CouponService(with: repository)
        var data = CouponData()
        data.expiresOn = Date()

        do {
            let _ = try service.createCoupon(with: data)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! CouponError, CouponError.invalidExpiryDate)
        }

        data.expiresOn = Date(timeIntervalSinceNow: 87000)
        let coupon = try! service.createCoupon(with: data)
        XCTAssertNotNil(coupon.data.expiresOn)
    }

    // Test updating coupon. We can updating everything other than the coupon's code.
    // Future coupon objects will have hidden the code. Only creation should show the code.
    func testCouponUpdate() {
        let store = TestStore()
        let repository = CouponRepository(with: store)
        let service = CouponService(with: repository)
        let data = CouponData()
        let coupon = try! service.createCoupon(with: data)
        let code = coupon.data.code!

        var patch = CouponPatch()     // test valid patch
        patch.note = "foobar"
        patch.balance = UnitMeasurement(value: 100.0, unit: .usd)
        let currentDate = Date()
        patch.disable = true
        patch.expiresOn = Date(timeIntervalSinceNow: 87000)

        let updatedCoupon = try! service.updateCoupon(for: coupon.id, with: patch)
        XCTAssertTrue(updatedCoupon.createdOn != updatedCoupon.updatedAt)
        XCTAssertEqual(updatedCoupon.data.note!, "foobar")
        XCTAssertEqual(updatedCoupon.data.balance.value, 100.0)
        XCTAssertTrue(updatedCoupon.data.disabledOn! > currentDate)
        XCTAssertEqual(updatedCoupon.data.expiresOn!, patch.expiresOn!)
        // Check that only the last 4 digits are shown in update.
        XCTAssertTrue(updatedCoupon.data.code!.starts(with: "XXXXXXXXXXXX"))
        XCTAssertEqual(updatedCoupon.data.code!.suffix(4), code.suffix(4))

        patch.expiresOn = Date()
        do {    // data is validated for update
            let _ = try service.updateCoupon(for: coupon.id, with: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! CouponError, CouponError.invalidExpiryDate)
        }
    }
}
