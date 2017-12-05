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
        let data = try? repository.createOrder(withData: orderData)
        XCTAssertNotNil(data)
        // creation and updated timestamps should be the same during creation
        XCTAssertEqual(data!.createdOn, data!.updatedAt)
        XCTAssertNotNil(repository.orders[data!.id!])   // valid order ID
        XCTAssertTrue(store.createCalled)       // store's create method called by repository
    }
}
