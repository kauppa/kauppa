import Foundation
import XCTest

import KauppaCore
import KauppaAccountsModel
import KauppaProductsModel
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService

class TestOrdersService: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()

    static var allTests: [(String, (TestOrdersService) -> () throws -> Void)] {
        return [
            ("Test order creation", testOrderCreation),
            ("Test order with invalid account", testOrderWithInvalidAccount),
            ("Test order with invalid product", testOrderWithInvalidProduct),
            ("Test order with ambiguous currencies", testOrderWithAmbiguousCurrencies),
            ("Test order with no products", testOrderWithNoProducts),
            ("Test order with product unavailable in inventory", testOrderWithUnavailableProduct),
            ("Test order zero quantity", testOrderWithZeroQuantity),
            ("Test order with one product having zero quantity", testOrderWithOneProductHavingZeroQuantity),
            ("Test order with duplicate products", testOrderWithDuplicateProducts),
            ("Test order deletion", testOrderDeletion),
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

    func testOrderCreation() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        productData.weight = UnitMeasurement(value: 5.0, unit: .gram)
        let product = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService)

        let inventoryUpdated = expectation(description: "product inventory updated")
        productsService.callbacks[product.id] = { patch in
            XCTAssertEqual(patch.inventory, 2)      // inventory amount changed
            inventoryUpdated.fulfill()
        }

        let orderData = OrderData(placedBy: account.id,
                                  products: [OrderUnit(id: product.id, quantity: 3)])
        let order = try! ordersService.createOrder(data: orderData)
        XCTAssertNotNil(order.id)
        // Make sure that the quantity is tracked while summing up values
        XCTAssertEqual(order.totalItems, 3)
        XCTAssertEqual(order.totalWeight.value, 15.0)
        XCTAssertEqual(order.totalPrice.value, 9.0)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    func testOrderWithNoProducts() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService)
        let orderData = OrderData(placedBy: account.id, products: [])
        do {
            let _ = try ordersService.createOrder(data: orderData)
            XCTFail()
        } catch let err {   // no products - failure
            XCTAssertTrue(err as! OrdersError == OrdersError.noItemsToProcess)
        }
    }

    func testOrderWithInvalidAccount() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService)
        let orderData = OrderData(placedBy: UUID(), products: [])
        do {
            let _ = try ordersService.createOrder(data: orderData)
            XCTFail()
        } catch let err {
            XCTAssertTrue(err as! AccountsError == AccountsError.invalidAccount)
        }
    }

    func testOrderWithInvalidProduct() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService)

        let orderData = OrderData(placedBy: account.id,
                                  products: [OrderUnit(id: UUID(), quantity: 3)])
        do {
            let _ = try ordersService.createOrder(data: orderData)
            XCTFail()
        } catch let err {   // random UUID - invalid product
            XCTAssertTrue(err as! ProductsError == ProductsError.invalidProduct)
        }
    }

    func testOrderWithUnavailableProduct() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let productData = ProductData(title: "", subtitle: "", description: "")
        // By default, inventory has zero items
        let product = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)
        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService)

        let orderData = OrderData(placedBy: account.id,
                                  products: [OrderUnit(id: product.id, quantity: 3)])
        do {
            let _ = try ordersService.createOrder(data: orderData)
            XCTFail()
        } catch let err {   // no products - failure
            XCTAssertTrue(err as! OrdersError == OrdersError.productUnavailable)
        }
    }

    func testOrderWithZeroQuantity() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        productData.weight = UnitMeasurement(value: 5.0, unit: .gram)
        let product = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService)
        // Products with zero quantity will be skipped - in this case, that's the
        // only product, and hence it fails
        let orderData = OrderData(placedBy: account.id,
                                  products: [OrderUnit(id: product.id, quantity: 0)])
        do {
            let _ = try ordersService.createOrder(data: orderData)
            XCTFail()
        } catch let err {
            XCTAssertTrue(err as! OrdersError == OrdersError.noItemsToProcess)
        }
    }

    func testOrderWithOneProductHavingZeroQuantity() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let anotherProductData = productData

        let firstProduct = try! productsService.createProduct(data: productData)
        let secondProduct = try! productsService.createProduct(data: anotherProductData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService)
        let orderData = OrderData(placedBy: account.id,
                                  products: [OrderUnit(id: firstProduct.id, quantity: 3),
                                             OrderUnit(id: secondProduct.id, quantity: 0)])
        let order = try! ordersService.createOrder(data: orderData)
        XCTAssertNotNil(order.id)
        // Second product (zero quantity) will be skipped while placing the order
        XCTAssertEqual(order.totalItems, 3)
    }

    func testOrderWithDuplicateProducts() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 10
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        productData.weight = UnitMeasurement(value: 5.0, unit: .gram)
        let product = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService)

        let inventoryUpdated = expectation(description: "product inventory updated")
        productsService.callbacks[product.id] = { patch in
            XCTAssertEqual(patch.inventory, 4)
            inventoryUpdated.fulfill()
        }
        // Multiple quantities of the same product
        let orderData = OrderData(placedBy: account.id,
                                  products: [OrderUnit(id: product.id, quantity: 3),
                                             OrderUnit(id: product.id, quantity: 3)])
        let order = try! ordersService.createOrder(data: orderData)
        XCTAssertNotNil(order.id)
        // All quantities are accumulated in the end
        XCTAssertEqual(order.totalItems, 6)
        XCTAssertEqual(order.totalWeight.value, 30.0)
        XCTAssertEqual(order.totalPrice.value, 18.0)

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }

    func testOrderWithAmbiguousCurrencies() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        productData.inventory = 10

        let firstProduct = try! productsService.createProduct(data: productData)
        productData.price.unit = .euro
        let secondProduct = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)
        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService)
        let orderData = OrderData(placedBy: account.id,
                                  products: [OrderUnit(id: firstProduct.id, quantity: 3),
                                             OrderUnit(id: secondProduct.id, quantity: 3)])
        do {
            let _ = try ordersService.createOrder(data: orderData)
            XCTFail()
        } catch let err {
            XCTAssertTrue(err as! OrdersError == OrdersError.ambiguousCurrencies)
        }
    }

    func testOrderDeletion() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        let product = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService)
        let orderData = OrderData(placedBy: account.id,
                                  products: [OrderUnit(id: product.id, quantity: 3)])
        let order = try! ordersService.createOrder(data: orderData)
        XCTAssertNotNil(order.id)
        let _ = try! ordersService.deleteOrder(id: order.id!)
    }
}
