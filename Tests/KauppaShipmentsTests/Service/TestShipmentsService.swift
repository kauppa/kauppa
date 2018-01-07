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
            ("Test pickup schedule", testPickupSchedule),
            ("Test pickup completion", testPickupCompletion),
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

    func testPickupSchedule() {
        let store = TestStore()
        let repository = ShipmentsRepository(withStore: store)
        let service = ShipmentsService(withRepository: repository, ordersService: ordersService)
        let _ = try! service.createShipment(forOrder: ordersService.order.id)
        let data = try! service.schedulePickup(forOrder: ordersService.order.id, data: PickupItems())
        XCTAssertEqual(data.status, .pickup)
    }

    func testPickupCompletion() {
        let store = TestStore()
        let repository = ShipmentsRepository(withStore: store)
        let service = ShipmentsService(withRepository: repository, ordersService: ordersService)
        ordersService.order.id = UUID()
        ordersService.order.shippingAddress = Address()
        let productId = UUID()
        ordersService.order.products = [OrderUnit(product: productId, quantity: 10)]
        var data = try! service.createShipment(forOrder: ordersService.order.id)
        do {    // cannot complete pickup if it's 'shipping'
            let _ = try service.completePickup(id: data.id)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ShipmentsError, .notScheduledForPickup)
        }

        var pickupData = PickupItems()
        pickupData.items = [OrderUnit(product: productId, quantity: 5)]
        data = try! service.schedulePickup(forOrder: ordersService.order.id, data: pickupData)
        let orderNotified = expectation(description: "orders service notified of pickup completion")
        ordersService.callback = { any in
            let (id, notifyData) = any as! (UUID, Shipment)
            XCTAssertEqual(id, self.ordersService.order.id)
            XCTAssertEqual(notifyData.status, .returned)
            XCTAssertEqual(notifyData.items.count, 1)
            XCTAssertEqual(notifyData.items[0].product, productId)
            XCTAssertEqual(notifyData.items[0].quantity, 5)     // 5 items have been picked up
            orderNotified.fulfill()
        }

        let updatedData = try! service.completePickup(id: data.id)
        XCTAssertEqual(updatedData.status, .returned)

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
}
