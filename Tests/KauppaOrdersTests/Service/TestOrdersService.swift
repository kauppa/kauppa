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
            ("Test order deletion", testOrderDeletion),
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
        let product = try! productsService.createProduct(data: productData)
        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)

        let inventoryUpdated = expectation(description: "product inventory updated")
        productsService.callbacks[product.id] = { patch in
            XCTAssertEqual(patch.inventory, 2)      // inventory amount changed
            inventoryUpdated.fulfill()
        }

        let orderData = OrderData(products: [OrderUnit(id: product.id, quantity: 3)])
        let order = try! ordersService.createOrder(data: orderData)
        XCTAssertNotNil(order.id)
        // Make sure that the quantity is tracked while summing up values
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
        let result = try? ordersService.createOrder(data: orderData)
        XCTAssertNil(result)    // no products - failure
    }

    func testOrderWithInvalidProduct() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let productsService = TestProductsService()
        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)

        let orderData = OrderData(products: [OrderUnit(id: UUID(), quantity: 3)])
        let result = try? ordersService.createOrder(data: orderData)
        XCTAssertNil(result)    // random UUID - invalid product
    }

    func testOrderWithUnavailableProduct() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let productsService = TestProductsService()
        let productData = ProductData(title: "", subtitle: "", description: "")
        // By default, inventory has zero items
        let product = try! productsService.createProduct(data: productData)
        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)

        let orderData = OrderData(products: [OrderUnit(id: product.id, quantity: 3)])
        let result = try? ordersService.createOrder(data: orderData)
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
        let product = try! productsService.createProduct(data: productData)
        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)
        // Products with zero quantity will be skipped - in this case, that's the
        // only product, and hence it fails
        let orderData = OrderData(products: [OrderUnit(id: product.id, quantity: 0)])
        let result = try? ordersService.createOrder(data: orderData)
        XCTAssertNil(result)
    }

    func testOrderWithOneProductHavinZeroQuantity() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let productsService = TestProductsService()
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let anotherProductData = productData

        let firstProduct = try! productsService.createProduct(data: productData)
        let secondProduct = try! productsService.createProduct(data: anotherProductData)

        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)
        let orderData = OrderData(products: [OrderUnit(id: firstProduct.id, quantity: 3),
                                             OrderUnit(id: secondProduct.id, quantity: 0)])
        let order = try! ordersService.createOrder(data: orderData)
        XCTAssertNotNil(order.id)
        // Second product (zero quantity) will be skipped while placing the order
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
        let product = try! productsService.createProduct(data: productData)
        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)

        let inventoryUpdated = expectation(description: "product inventory updated")
        productsService.callbacks[product.id] = { patch in
            XCTAssertEqual(patch.inventory, 4)
            inventoryUpdated.fulfill()
        }
        // Multiple quantities of the same product
        let orderData = OrderData(products: [OrderUnit(id: product.id, quantity: 3),
                                             OrderUnit(id: product.id, quantity: 3)])
        let order = try! ordersService.createOrder(data: orderData)
        XCTAssertNotNil(order.id)
        // All quantities are accumulated in the end
        XCTAssertEqual(order.totalItems, 6)
        XCTAssertEqual(order.totalWeight.value, 30.0)
        XCTAssertEqual(order.totalPrice, 18.0)

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }

    func testOrderDeletion() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let productsService = TestProductsService()
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        let product = try! productsService.createProduct(data: productData)
        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)
        let orderData = OrderData(products: [OrderUnit(id: product.id, quantity: 3)])
        let order = try! ordersService.createOrder(data: orderData)
        XCTAssertNotNil(order.id)
        let _ = try! ordersService.deleteOrder(id: order.id!)
    }
}
