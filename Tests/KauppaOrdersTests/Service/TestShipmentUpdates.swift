import Foundation
import XCTest

import KauppaCore
import KauppaProductsModel
import KauppaShipmentsModel
@testable import KauppaAccountsModel
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService

class TestShipmentUpdates: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    let shippingService = TestShipmentsService()

    static var allTests: [(String, (TestShipmentUpdates) -> () throws -> Void)] {
        return [
            ("Test order item pickup", testItemPickup),
        ]
    }

    override func setUp() {
        productsService.products = [:]
        accountsService.accounts = [:]
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testItemPickup() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product1 = try! productsService.createProduct(data: productData)
        productData.price = UnitMeasurement(value: 10.0, unit: .usd)
        let product2 = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(product: product1.id, quantity: 3),
                                             OrderUnit(product: product2.id, quantity: 2)])
        var order = try! ordersService.createOrder(data: orderData)
        var shipmentData = Shipment()
        shipmentData.items = [OrderUnit(product: product1.id, quantity: 2),
                              OrderUnit(product: product2.id, quantity: 1)]
        shipmentData.status = .returned

        do {    // items haven't been delivered yet - so failure
            let _ = try ordersService.updateShipment(forId: order.id, data: shipmentData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .unfulfilledItem(product1.id))
        }

        // imitate that the items have been delivered and scheduled for pickup
        order.products[0].status = OrderUnitStatus(quantity: 3)
        order.products[0].status!.pickupQuantity = 2
        order.products[1].status = OrderUnitStatus(quantity: 2)
        order.products[1].status!.pickupQuantity = 1
        order = try! repository.updateOrder(withData: order)

        let _ = try! ordersService.updateShipment(forId: order.id, data: shipmentData)
        let updatedOrder = try! repository.getOrder(id: order.id)
        // pickup quantity has been reset to zero
        XCTAssertEqual(updatedOrder.products[0].status!.pickupQuantity, 0)
        XCTAssertEqual(updatedOrder.products[1].status!.pickupQuantity, 0)
        // refundable quantity has been changed
        XCTAssertEqual(updatedOrder.products[0].status!.refundableQuantity, 2)
        XCTAssertEqual(updatedOrder.products[1].status!.refundableQuantity, 1)
        // fulfilled quantity has been reduced
        XCTAssertEqual(updatedOrder.products[0].status!.fulfilledQuantity, 1)
        XCTAssertEqual(updatedOrder.products[1].status!.refundableQuantity, 1)
        XCTAssertEqual(updatedOrder.shipments[shipmentData.id]!, .returned)

        shipmentData.items = [OrderUnit(product: UUID(), quantity: 1)]

        do {    // item not found in order - failure
            let _ = try ordersService.updateShipment(forId: order.id, data: shipmentData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidOrderItem)
        }

        shipmentData.items = [OrderUnit(product: product1.id, quantity: 3)]
        do {    // No pickups have been scheduled yet
            let _ = try ordersService.updateShipment(forId: order.id, data: shipmentData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidPickupQuantity(product1.id, 0))
        }

        repository.orders[order.id]!.products[0].status!.pickupQuantity = 3
        shipmentData.items = [OrderUnit(product: product1.id, quantity: 3)]
        do {    // shipment has picked up 3 items, but only 1 item has been fulfilled
            let _ = try ordersService.updateShipment(forId: order.id, data: shipmentData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .unfulfilledItem(product1.id))
        }
    }
}
