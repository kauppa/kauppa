import Foundation
import XCTest

@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository

class TestOrdersRepository: XCTestCase {
    static var allTests: [(String, (TestOrdersRepository) -> () throws -> Void)] {
        return [
            ("Test order creation", testOrderCreation),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testOrderCreation() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let orderData = Order()
        let data = repository.createOrder(withData: orderData)
        XCTAssertNotNil(data)
        XCTAssertEqual(data!.createdOn, data!.updatedAt)
        XCTAssertNotNil(repository.orders[data!.id!])
        XCTAssertTrue(store.createCalled)
    }
}
