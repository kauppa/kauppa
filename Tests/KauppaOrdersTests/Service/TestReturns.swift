import Foundation
import XCTest

import KauppaCore
import KauppaProductsModel
import KauppaShipmentsModel
@testable import KauppaAccountsModel
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService

class TestReturns: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    var shippingService = TestShipmentsService()

    static var allTests: [(String, (TestReturns) -> () throws -> Void)] {
        return [
            ("Test full return", testFullReturn),
            ("Test partial returns", testPartialReturns),
            ("Test cancelled order", testCancelledOrder),
            ("Test invalid return data", testInvalidReturns),
            ("Test double pickup", testDoublePickup),
        ]
    }

    override func setUp() {
        productsService.products = [:]
        accountsService.accounts = [:]
        shippingService = TestShipmentsService()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFullReturn() {
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
        var initial = try! ordersService.createOrder(data: orderData)   // create an order
        // Set the data which is usually set by shipping services.
        initial.products[0].status = OrderUnitStatus(quantity: 3)
        initial.products[0].status!.fulfillment = .fulfilled
        initial.products[1].status = OrderUnitStatus(quantity: 2)
        initial.products[1].status!.fulfillment = .fulfilled
        let order = try! repository.updateOrder(withData: initial)
        let pickupScheduled = expectation(description: "Order items have been scheduled for pickup")

        // Make sure that shipments service is called for pickup
        shippingService.shipment = Shipment(id: UUID(), createdOn: Date(), updatedAt: Date(),
                                            orderId: UUID(), address: Address())
        shippingService.shipment!.status = .pickup
        shippingService.callback = { any in
            let (id, data) = any as! (UUID, PickupItems)
            XCTAssertEqual(id, order.id)
            XCTAssertEqual(data.items.count, 2)
            XCTAssertEqual(data.items[0].product, product1.id)
            XCTAssertEqual(data.items[0].quantity, 3)
            XCTAssertEqual(data.items[0].product, product2.id)
            XCTAssertEqual(data.items[0].quantity, 2)
            pickupScheduled.fulfill()
        }

        var pickupData = PickupData()
        pickupData.pickupAll = true
        let updatedOrder = try! ordersService.returnOrder(id: order.id, data: pickupData)
        XCTAssertEqual(updatedOrder.products[0].status!.pickupQuantity, 3)
        XCTAssertEqual(updatedOrder.products[1].status!.pickupQuantity, 2)
        let id = shippingService.shipment!.id
        XCTAssertEqual(updatedOrder.shipments[id]!, .pickup)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    func testPartialReturns() {
        // TODO
    }

    func testCancelledOrder() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product = try! productsService.createProduct(data: productData)
        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)
        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(product: product.id, quantity: 3)])
        let order = try! ordersService.createOrder(data: orderData)
        let _ = try! ordersService.cancelOrder(id: order.id)
        let pickupData = PickupData()
        do {
            let _ = try ordersService.returnOrder(id: order.id, data: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .cancelledOrder)
        }
    }

    func testInvalidReturns() {
        // TODO
    }

    func testDoublePickup() {
        // TODO: Requires `pickupQuantity` in `OrderUnitStatus`
    }
}
