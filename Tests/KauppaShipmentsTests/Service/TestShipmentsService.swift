import Foundation
import XCTest

import KauppaCore
import KauppaOrdersModel
@testable import KauppaAccountsModel
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
        ordersService.order.shippingAddress = Address()
        ordersService.order.products = [OrderUnit(product: UUID(), quantity: 10)]
        let data = try! service.createShipment(forOrder: id)
        XCTAssertEqual(data.createdOn, data.updatedAt)      // created and updated timestamps are equal
        XCTAssertEqual(data.orderId, id)    // shipment is bound to this order ID.
        XCTAssertEqual(data.items.count, 1)     // order unit is obtained from orders service.
        XCTAssertEqual(data.items[0].product, ordersService.order.products[0].product)
    }
}
