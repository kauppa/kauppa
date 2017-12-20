import Foundation
import XCTest

import KauppaCore
import KauppaAccountsModel
import KauppaProductsModel
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService

class TestRefunds: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()

    static var allTests: [(String, (TestRefunds) -> () throws -> Void)] {
        return [
            ("Test full refund", testFullRefund)
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

    func testFullRefund() {
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
                                          productsService: productsService)
        let orderData = OrderData(placedBy: account.id,
                                  products: [OrderUnit(product: product1.id, quantity: 3),
                                             OrderUnit(product: product2.id, quantity: 2)])
        var initial = try! ordersService.createOrder(data: orderData)
        // Set the data which is usually set by payments and shipping services.
        initial.paymentStatus = .paid
        initial.products[0].status = OrderUnitStatus(quantity: 3)
        initial.products[0].status!.fulfillment = .fulfilled
        initial.products[1].status = OrderUnitStatus(quantity: 2)
        initial.products[1].status!.fulfillment = .fulfilled
        let order = try! repository.updateOrder(withData: initial)

        var refundData = RefundData(reason: "I hate you!")
        refundData.fullRefund = true
        let updatedOrder = try! ordersService.initiateRefund(forId: order.id!, data: refundData)
        // Check the refund data
        let refund = store.refunds[updatedOrder.refunds[0]]!
        XCTAssertEqual(refund.amount.value, 29.0)   // total refund amount
        XCTAssertEqual(refund.amount.unit, .usd)
        XCTAssertEqual(refund.items.count, 2)
        XCTAssertEqual(refund.items[0].product, product1.id)
        XCTAssertEqual(refund.items[0].quantity, 3)
        XCTAssertEqual(refund.items[1].product, product2.id)
        XCTAssertEqual(refund.items[1].quantity, 2)
        XCTAssertEqual(refund.orderId, order.id!)   // refund has order ID
        XCTAssertEqual(refund.reason, refundData.reason)
        // Check the order data
        XCTAssertEqual(updatedOrder.paymentStatus, .refunded)
        // We've revoked everything back from the customer. So, there's
        // no fulfillment.
        XCTAssertNil(updatedOrder.fulfillment)
        XCTAssertNil(updatedOrder.products[0].status)
        XCTAssertNil(updatedOrder.products[1].status)
        XCTAssertEqual(updatedOrder.refunds, [refund.id])   // refund is listed in order
    }
}
