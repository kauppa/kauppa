import Foundation
import XCTest

import KauppaCore
@testable import KauppaShipmentsModel
@testable import KauppaShipmentsRepository
@testable import KauppaShipmentsService

class TestShipmentsService: XCTestCase {
    var ordersService = TestOrdersService()

    static var allTests: [(String, (TestShipmentsService) -> () throws -> Void)] {
        return [
            ("Test successful shipment creation", testShipmentCreation),
        ]
    }

    override func setUp() {
        ordersService = TestOrdersService()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testShipmentCreation() {
        let store = TestStore()
        let repository = ShipmentsRepository(withStore: store)
        let service = ShipmentsService(withRepository: repository, ordersService: ordersService)
        let id = UUID()
        ordersService.order.id = id
        let data = try! service.createShipment(forOrder: id)
        XCTAssertEqual(data.createdOn, data.updatedAt)      // created and updated timestamps are equal
        XCTAssertEqual(data.orderId, id)    // shipment is bound to this order ID.
    }
}
