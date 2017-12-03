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
            ("Test order creation", testOrderCreation),
            ("Test order with invalid product", testOrderWithInvalidProduct),
            ("Test order with no products", testOrderWithNoProducts),
            ("Test order with product unavailable in inventory", testOrderWithUnavailableProduct),
            ("Test order zero quantity", testOrderWithZeroQuantity),
            ("Test order with one product having zero quantity", testOrderWithOneProductHavinZeroQuantity),
            ("Test order with duplicate products", testOrderWithDuplicateProducts),
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

    func testOrderWithNoProducts() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let productsService = TestProductsService()
        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)
        let orderData = OrderData(products: [])
        let result = ordersService.createOrder(data: orderData)
        XCTAssertNil(result)
    }

    func testOrderWithInvalidProduct() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let productsService = TestProductsService()
        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)

        let orderData = OrderData(products: [OrderUnit(id: UUID(), quantity: 3)])
        let result = ordersService.createOrder(data: orderData)
        XCTAssertNil(result)
    }

    func testOrderWithUnavailableProduct() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let productsService = TestProductsService()
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.weight = UnitMeasurement(value: 5.0, unit: .gram)
        let product = productsService.createProduct(data: productData)!
        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)

        let orderData = OrderData(products: [OrderUnit(id: product.id, quantity: 3)])
        let result = ordersService.createOrder(data: orderData)
        XCTAssertNil(result)
    }

    func testOrderWithZeroQuantity() {
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

        let orderData = OrderData(products: [OrderUnit(id: product.id, quantity: 0)])
        let result = ordersService.createOrder(data: orderData)
        XCTAssertNil(result)
    }

    func testOrderWithOneProductHavinZeroQuantity() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let productsService = TestProductsService()
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 10
        var anotherProductData = productData
        anotherProductData.inventory = 0

        let firstProduct = productsService.createProduct(data: productData)!
        let secondProduct = productsService.createProduct(data: anotherProductData)!

        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)
        let orderData = OrderData(products: [OrderUnit(id: firstProduct.id, quantity: 3),
                                             OrderUnit(id: secondProduct.id, quantity: 0)])
        let order = ordersService.createOrder(data: orderData)!
        XCTAssertNotNil(order.id)
        XCTAssertEqual(order.totalItems, 3)
    }

    func testOrderWithDuplicateProducts() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let productsService = TestProductsService()
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 10
        productData.price = 3.0
        productData.weight = UnitMeasurement(value: 5.0, unit: .gram)
        let product = productsService.createProduct(data: productData)!
        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)

        let inventoryUpdated = expectation(description: "product inventory updated")
        productsService.callbacks[product.id] = { patch in
            XCTAssertEqual(patch.inventory, 4)
            inventoryUpdated.fulfill()
        }

        let orderData = OrderData(products: [OrderUnit(id: product.id, quantity: 3),
                                             OrderUnit(id: product.id, quantity: 3)])
        let order = ordersService.createOrder(data: orderData)!
        XCTAssertNotNil(order.id)
        XCTAssertEqual(order.totalItems, 6)
        XCTAssertEqual(order.totalWeight.value, 30.0)
        XCTAssertEqual(order.totalPrice, 18.0)

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
}
