import Foundation
import XCTest

import KauppaCore
import KauppaCartModel
@testable import KauppaAccountsModel
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService
@testable import KauppaProductsModel

class TestRefunds: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    var shippingService = TestShipmentsService()
    var couponService = TestCouponService()
    var taxService = TestTaxService()

    static var allTests: [(String, (TestRefunds) -> () throws -> Void)] {
        return [
            ("Test full refund", testFullRefund),
            ("Test partial refunds", testPartialRefunds),
            ("Test cancelled order", testCancelledOrder),
            ("Test unpaid refund", testUnpaidRefund),
            ("Test invalid refund data", testInvalidRefunds),
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

    // A refund can be issued once items have been taken back (i.e, when there are refundable items)
    // A full refund happens for all refundable items in an order. This will update the corresponding
    // quantity fields and the item status fields.
    func testFullRefund() {
        let store = TestStore()
        let repository = OrdersRepository(with: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product1 = try! productsService.createProduct(with: productData, from: Address())
        productData.price = UnitMeasurement(value: 10.0, unit: .usd)
        let product2 = try! productsService.createProduct(with: productData, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        let ordersService = OrdersService(with: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(for: product1.id, with: 3),
                                             OrderUnit(for: product2.id, with: 2)])
        var initial = try! ordersService.createOrder(with: orderData)
        // Set the data which is usually set by payments and shipping services.
        initial.paymentStatus = .paid
        initial.products[0].status = OrderUnitStatus(for: 0)
        initial.products[0].status!.refundableQuantity = 3
        initial.products[1].status = OrderUnitStatus(for: 0)
        initial.products[1].status!.refundableQuantity = 2
        let order = try! repository.updateOrder(with: initial)

        var refundData = RefundData(reason: "")
        do {
            let _ = try ordersService.initiateRefund(for: order.id, with: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidReason)
        }

        refundData = RefundData(reason: "I hate you!")
        refundData.fullRefund = true
        let updatedOrder = try! ordersService.initiateRefund(for: order.id, with: refundData)
        // Check the order data
        XCTAssertEqual(updatedOrder.paymentStatus, .refunded)
        // We've revoked everything back from the customer, so there's no fulfillment.
        XCTAssertNil(updatedOrder.fulfillment)
        XCTAssertNil(updatedOrder.products[0].status)
        XCTAssertNil(updatedOrder.products[1].status)
        // Check the refund data
        let refund = store.refunds[updatedOrder.refunds[0]]!
        XCTAssertEqual(updatedOrder.refunds, [refund.id])   // refund is listed in order
        XCTAssertEqual(refund.amount.value, 29.0)   // total refund amount
        XCTAssertEqual(refund.amount.unit, .usd)
        XCTAssertEqual(refund.items.count, 2)
        XCTAssertEqual(refund.items[0].product, product1.id)
        XCTAssertEqual(refund.items[0].quantity, 3)
        XCTAssertEqual(refund.items[1].product, product2.id)
        XCTAssertEqual(refund.items[1].quantity, 2)
        XCTAssertEqual(refund.orderId, order.id)    // refund has order ID
        XCTAssertEqual(refund.reason, refundData.reason)
    }

    // Partial refunds happen when specific items can be refunded to the customer.
    func testPartialRefunds() {
        let store = TestStore()
        let repository = OrdersRepository(with: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product1 = try! productsService.createProduct(with: productData, from: Address())
        productData.price = UnitMeasurement(value: 10.0, unit: .usd)
        let product2 = try! productsService.createProduct(with: productData, from: Address())
        productData.price = UnitMeasurement(value: 5.0, unit: .usd)
        let product3 = try! productsService.createProduct(with: productData, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        let ordersService = OrdersService(with: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(for: product1.id, with: 3),
                                             OrderUnit(for: product2.id, with: 2),
                                             OrderUnit(for: product3.id, with: 1)])
        var initial = try! ordersService.createOrder(with: orderData)
        // Set the data which is usually set by payments and shipping services.
        initial.paymentStatus = .paid
        initial.products[0].status = OrderUnitStatus(for: 0)
        initial.products[0].status!.refundableQuantity = 3
        initial.products[1].status = OrderUnitStatus(for: 0)
        initial.products[1].status!.refundableQuantity = 2
        initial.products[2].status = OrderUnitStatus(for: 0)
        initial.products[2].status!.refundableQuantity = 1
        let order = try! repository.updateOrder(with: initial)

        var refundData = RefundData(reason: "Boo!")
        refundData.units = [CartUnit(for: product1.id, with: 1),
                            CartUnit(for: product3.id, with: 1)]
        let updatedOrder = try! ordersService.initiateRefund(for: order.id, with: refundData)
        XCTAssertEqual(updatedOrder.refunds.count, 1)
        let refund1 = store.refunds[updatedOrder.refunds[0]]!
        XCTAssertEqual(refund1.amount.value, 8.0)
        XCTAssertEqual(refund1.items.count, 2)
        XCTAssertEqual(refund1.items[0].product, product1.id)
        XCTAssertEqual(refund1.items[0].quantity, 1)
        XCTAssertEqual(refund1.items[1].product, product3.id)
        XCTAssertEqual(refund1.items[1].quantity, 1)
        // Some of the data will be set to partial fulfillment
        XCTAssertEqual(updatedOrder.paymentStatus, .partialRefund)
        XCTAssertEqual(updatedOrder.fulfillment, .partial)
        XCTAssertEqual(updatedOrder.products[0].status!.refundableQuantity, 2)
        XCTAssertEqual(updatedOrder.products[0].status!.fulfillment, .partial)
        // `product3` has been refunded entirely, so it's `nil`
        XCTAssertNil(updatedOrder.products[2].status)

        // Now try and refund the remaining units
        refundData.units = [CartUnit(for: product1.id, with: 2),
                            CartUnit(for: product2.id, with: 2)]
        let finalUpdate = try! ordersService.initiateRefund(for: order.id, with: refundData)
        XCTAssertEqual(finalUpdate.refunds.count, 2)
        XCTAssertEqual(finalUpdate.paymentStatus, .refunded)
        XCTAssertNil(finalUpdate.fulfillment)
        // Ensure complete refund by now
        let refund2 = store.refunds[finalUpdate.refunds[1]]!
        XCTAssertEqual(refund2.amount.value, 26.0)
        XCTAssertEqual(refund2.items.count, 2)
        XCTAssertEqual(refund2.items[0].product, product1.id)
        XCTAssertEqual(refund2.items[0].quantity, 2)
        XCTAssertEqual(refund2.items[1].product, product2.id)
        XCTAssertEqual(refund2.items[1].quantity, 2)

        do {   // now, try refunding again
            let _ = try ordersService.initiateRefund(for: order.id, with: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .refundedOrder)
        }
    }

    // Cancelled orders cannot be refunded.
    func testCancelledOrder() {
        let store = TestStore()
        let repository = OrdersRepository(with: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product = try! productsService.createProduct(with: productData, from: Address())
        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)
        let ordersService = OrdersService(with: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(for: product.id, with: 3)])
        let order = try! ordersService.createOrder(with: orderData)
        let _ = try! ordersService.cancelOrder(for: order.id)
        let refundData = RefundData(reason: "Booya!")
        do {
            let _ = try ordersService.initiateRefund(for: order.id, with: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .cancelledOrder)
        }
    }

    // If the payment hasn't been received for an order, then it cannot be refunded.
    func testUnpaidRefund() {
        let store = TestStore()
        let repository = OrdersRepository(with: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product = try! productsService.createProduct(with: productData, from: Address())
        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)
        let ordersService = OrdersService(with: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(for: product.id, with: 3)])
        var order = try! ordersService.createOrder(with: orderData)
        let refundData = RefundData(reason: "Booya!")
        do {    // by default, the payment status is 'pending'
            let _ = try ordersService.initiateRefund(for: order.id, with: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .paymentNotReceived)
        }

        order.paymentStatus = .failed   // check for failed payment
        let _ = try! repository.updateOrder(with: order)
        do {
            let _ = try ordersService.initiateRefund(for: order.id, with: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .paymentNotReceived)
        }
    }

    // A number of cases when refund can fail - item doesn't exist in order, item hasn't been fulfilled,
    // item hasn't been returned, etc.
    func testInvalidRefunds() {
        let store = TestStore()
        let repository = OrdersRepository(with: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product1 = try! productsService.createProduct(with: productData, from: Address())
        productData.price = UnitMeasurement(value: 10.0, unit: .usd)
        let product2 = try! productsService.createProduct(with: productData, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        let ordersService = OrdersService(with: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(for: product1.id, with: 3),
                                             OrderUnit(for: product2.id, with: 2)])
        var initial = try! ordersService.createOrder(with: orderData)
        // Set the data which is usually set by payments and shipping services.
        initial.paymentStatus = .paid
        initial.products[0].status = OrderUnitStatus(for: 0)
        initial.products[0].status!.refundableQuantity = 3
        let order = try! repository.updateOrder(with: initial)

        var refundData = RefundData(reason: "Boo!")

        refundData.units = [CartUnit(for: UUID(), with: 2)]
        do {    // Test invalid product
            let _ = try ordersService.initiateRefund(for: order.id, with: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidOrderItem)
        }

        refundData.units = [CartUnit(for: product2.id, with: 2)]
        do {    // Test unfulfilled item
            let _ = try ordersService.initiateRefund(for: order.id, with: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .unfulfilledItem(product2.id))
        }

        refundData.units = [CartUnit(for: product1.id, with: 5)]
        do {    // Test invalid quantity for refundable item
            let _ = try ordersService.initiateRefund(for: order.id, with: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidRefundQuantity(product1.id, 3))
        }

        refundData.units = []
        do {    // Test no items
            let _ = try ordersService.initiateRefund(for: order.id, with: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .noItemsToProcess)
        }
    }
}
