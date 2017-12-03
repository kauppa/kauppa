import Foundation
import XCTest

import KauppaCore
import KauppaProductsModel
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService

class TestOrdersService: XCTestCase {

    static var allTests: [(String, (TestOrdersService) -> () throws -> Void)] {
        return [
            ("Test order creation", testOrderCreation)
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
        let productsService = TestProductsService()
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = 3.0
        productData.weight = UnitMeasurement(value: 5.0, unit: .gram)
        let product = productsService.createProduct(data: productData)!
        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)

        let inventoryUpdated = expectation(description: "product inventory updated")
        productsService.callbacks[product.id] = { patch in
            XCTAssertEqual(patch.inventory, 2)
            inventoryUpdated.fulfill()
        }

        let orderData = OrderData(products: [OrderUnit(id: product.id, quantity: 3)])
        let order = ordersService.createOrder(data: orderData)!
        XCTAssertNotNil(order.id)
        XCTAssertEqual(order.totalItems, 3)
        XCTAssertEqual(order.totalWeight.value, 15.0)
        XCTAssertEqual(order.totalPrice, 9.0)

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
}
