import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaCouponModel
@testable import KauppaCouponRepository

class TestCouponRepository: XCTestCase {
    static var allTests: [(String, (TestCouponRepository) -> () throws -> Void)] {
        return [
            ("Test creating coupon", testCouponCreation),
            ("Test coupon update", testCouponUpdate),
            ("Test store function calls", testStoreCalls),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Test creating a coupon in the repository. Validation happens only in the service end.
    // Here, we only check for proper calls to store and caching in repository itself.
    func testCouponCreation() {
        let store = TestStore()
        let repository = CouponRepository(withStore: store)
        var data = CouponData()
        data.code = "foobar"    // invalid code (but, this is checked by service)
        let coupon = try! repository.createCoupon(data: data)
        XCTAssertTrue(store.createCalled)   // store has been called for creation
        XCTAssertNotNil(repository.coupons[coupon.id])  // repository has the coupon.
        XCTAssertNotNil(repository.codes[coupon.data.code!])  // repository also caches code
    }

    // Updating the coupon in repository should update the cache and the store
    func testCouponUpdate() {
        let store = TestStore()
        let repository = CouponRepository(withStore: store)
        var data = CouponData()
        data.code = "foobar"
        let coupon = try! repository.createCoupon(data: data)
        XCTAssertEqual(coupon.createdOn, coupon.updatedAt)

        data.note = "foobar"
        let updatedCoupon = try! repository.updateCouponData(id: coupon.id, data: data)
        // We're just testing the function calls (extensive testing is done in service)
        XCTAssertEqual(updatedCoupon.data.note!, "foobar")
        XCTAssertTrue(updatedCoupon.createdOn != updatedCoupon.updatedAt)
        XCTAssertTrue(store.updateCalled)   // update called on store
    }

    // Test the repository for proper store calls. If the item doesn't exist in the cache, then
    // it should get from the store and cache it. Re-getting the item shouldn't call the store.
    func testStoreCalls() {
        let store = TestStore()
        let repository = CouponRepository(withStore: store)
        var data = CouponData()
        data.code = "foobar"
        let coupon = try! repository.createCoupon(data: data)
        repository.coupons = [:]      // clear the coupons
        let _ = try? repository.getCoupon(forId: coupon.id)
        XCTAssertTrue(store.getCalled)  // this should've called the store
        repository.codes = [:]      // clear the codes
        let _ = try? repository.getCoupon(forCode: coupon.data.code!)
        XCTAssertTrue(store.codeGetCalled)  // this should've called again for code
        store.getCalled = false         // now, pretend that we never called the store
        let _ = try? repository.getCoupon(forId: coupon.id)
        // store shouldn't be called, because it was recently fetched by the repository
        XCTAssertFalse(store.getCalled)
    }
}
