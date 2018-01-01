import Foundation
import XCTest

import KauppaCore
import KauppaCartModel
@testable import KauppaAccountsModel
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService
@testable import KauppaProductsModel
@testable import KauppaShipmentsModel

class TestShipmentUpdates: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    var shippingService = TestShipmentsService()
    var couponService = TestCouponService()
    var taxService = TestTaxService()

    static var allTests: [(String, (TestShipmentUpdates) -> () throws -> Void)] {
        return [
            ("Test order item pickup", testItemPickup),
            ("Test item delivery", testItemDelivery),
        ]
    }

    override func setUp() {
        productsService.products = [:]
        accountsService.accounts = [:]
        shippingService = TestShipmentsService()
        couponService = TestCouponService()
        taxService = TestTaxService()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Test pickup of items - items can be picked only when they've been fulfilled by the customer.
    // All other cases should fail.
    func testItemPickup() {
        let store = TestStore()
        let repository = OrdersRepository(with: store)
        var productData1 = Product(title: "", subtitle: "", description: "")
        productData1.inventory = 5
        productData1.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product1 = try! productsService.createProduct(with: productData1, from: Address())

        var productData2 = Product(title: "", subtitle: "", description: "")
        productData2.inventory = 5
        productData2.price = UnitMeasurement(value: 10.0, unit: .usd)
        let product2 = try! productsService.createProduct(with: productData2, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        let ordersService = OrdersService(with: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(for: product1.id!, with: 3),
                                             OrderUnit(for: product2.id!, with: 2)])
        var order = try! ordersService.createOrder(with: orderData)
        var shipmentData = Shipment()
        shipmentData.items = [CartUnit(for: product1.id!, with: 2),
                              CartUnit(for: product2.id!, with: 1)]
        shipmentData.status = .returned

        do {    // items haven't been delivered yet - so failure
            let _ = try ordersService.updateShipment(for: order.id, with: shipmentData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .unfulfilledItem(product1.id!))
        }

        // imitate that the items have been delivered and scheduled for pickup
        order.products[0].status = OrderUnitStatus(for: 3)
        order.products[0].status!.pickupQuantity = 2
        order.products[1].status = OrderUnitStatus(for: 2)
        order.products[1].status!.pickupQuantity = 1
        order = try! repository.updateOrder(with: order)

        let _ = try! ordersService.updateShipment(for: order.id, with: shipmentData)
        let updatedOrder = try! repository.getOrder(for: order.id)
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

        shipmentData.items = [CartUnit(for: UUID(), with: 1)]

        do {    // item not found in order - failure
            let _ = try ordersService.updateShipment(for: order.id, with: shipmentData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidOrderItem)
        }

        shipmentData.items = [CartUnit(for: product1.id!, with: 3)]
        do {    // No pickups have been scheduled yet
            let _ = try ordersService.updateShipment(for: order.id, with: shipmentData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidPickupQuantity(product1.id!, 0))
        }

        repository.orders[order.id]!.products[0].status!.pickupQuantity = 3
        shipmentData.items = [CartUnit(for: product1.id!, with: 3)]
        do {    // shipment has picked up 3 items, but only 1 item has been fulfilled
            let _ = try ordersService.updateShipment(for: order.id, with: shipmentData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .unfulfilledItem(product1.id!))
        }
    }

    // Once shipment service notifies about a delivery event, order should be updated accordingly.
    func testItemDelivery() {
        let store = TestStore()
        let repository = OrdersRepository(with: store)
        var productData1 = Product(title: "", subtitle: "", description: "")
        productData1.inventory = 5
        productData1.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product1 = try! productsService.createProduct(with: productData1, from: Address())

        var productData2 = Product(title: "", subtitle: "", description: "")
        productData2.inventory = 5
        productData2.price = UnitMeasurement(value: 10.0, unit: .usd)
        let product2 = try! productsService.createProduct(with: productData2, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        let ordersService = OrdersService(with: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(for: product1.id!, with: 3),
                                             OrderUnit(for: product2.id!, with: 2)])
        var order = try! ordersService.createOrder(with: orderData)

        var shipmentData = Shipment()
        shipmentData.items = [CartUnit(for: product1.id!, with: 3),
                              CartUnit(for: product2.id!, with: 3)]
        shipmentData.status = .delivered
        do {    // one two items were supposed to deliver for product2
            let _ = try ordersService.updateShipment(for: order.id, with: shipmentData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidDeliveryQuantity(product2.id!, 2))
        }

        shipmentData.items[1] = CartUnit(for: product2.id!, with: 2)
        let _ = try! ordersService.updateShipment(for: order.id, with: shipmentData)
        order = try! repository.getOrder(for: order.id)
        XCTAssertEqual(order.products[0].status!.fulfilledQuantity, 3)
        XCTAssertEqual(order.products[1].status!.fulfilledQuantity, 2)
    }
}
