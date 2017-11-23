import Foundation
import XCTest

@testable import KauppaCore

class TestOrdersService: XCTestCase {
    var store = MemoryStore()

    static var allTests: [(String, (TestOrdersService) -> () throws -> Void)] {
        return [
            ("OrderCreation", testOrderCreation),
            ("OrderInvalidProduct", testOrderInvalidProduct),
            ("OrderCancellation", testOrderCancellation),
        ]
    }

    override func setUp() {
        store = MemoryStore()

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func createProductData(name: String = "Foo",
                           lengthCm: Double = 5.0,
                           widthCm: Double = 4.0,
                           heightCm: Double = 50.0,
                           weightG: Double = 100.0,
                           inventory: Int = 5,
                           price: Double = 15.0) -> ProductData {
        let string = """
            {
                "title": "\(name)",
                "subtitle": "Bar",
                "description": "foo bar",
                "size": {
                    "length": { "value": \(lengthCm), "unit": "cm" },
                    "width": { "value": \(widthCm), "unit": "cm" },
                    "height": { "value": \(heightCm), "unit": "cm" }
                },
                "color": "black",
                "weight": {
                    "value": \(weightG),
                    "unit": "g"
                },
                "inventory": \(inventory),
                "images": [],
                "price": \(price),
            }
        """

        let jsonData = string.data(using: .utf8)!
        let data = try! JSONDecoder().decode(ProductData.self, from: jsonData)
        return data
    }

    func testOrderCreation() {
        let creation = expectation(description: "Order created")
        let inventoryUpdate = expectation(description: "Inventory updated")
        let product1 = self.createProductData(name: "Echo", lengthCm: 8.0,
                                              widthCm: 8.0, heightCm: 15.0,
                                              weightG: 1000.0, price: 100.0)
        let product2 = self.createProductData(name: "iPhone 6s", lengthCm: 7.0,
                                              widthCm: 0.8, heightCm: 14.0,
                                              weightG: 150.0, inventory: 2, price: 300.0)

        let product1Data = store.createProduct(data: product1)
        XCTAssertNotNil(product1Data)
        let product2Data = store.createProduct(data: product2)
        XCTAssertNotNil(product2Data)
        let productId1 = product1Data!.id
        let productId2 = product2Data!.id

        let order = OrderData(products: [OrderUnit(id: productId1, quantity: 2),
                                         OrderUnit(id: productId2, quantity: 1)])
        let orderData = store.createOrder(order: order)!
        let orderId = Array(self.store.orders.keys)[0]
        XCTAssertEqual(orderId, orderData.id)
        XCTAssertEqual(orderData.totalItems, 3)
        XCTAssertEqual(orderData.totalPrice, 500.0)
        XCTAssert(orderData.totalWeight.value == 2.15)
        XCTAssert(orderData.totalWeight.unit == Weight.kilogram)
        creation.fulfill()

        let storeProduct1 = self.store.products[productId1]!
        XCTAssertEqual(storeProduct1.data.inventory, 3)
        let storeProduct2 = self.store.products[productId2]!
        XCTAssertEqual(storeProduct2.data.inventory, 1)
        inventoryUpdate.fulfill()

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }

    func testOrderInvalidProduct() {
        let orderIgnore = expectation(description: "Order ignored")
        let orderPlaced = expectation(description: "Order placed")
        let product = self.createProductData()
        let productData = store.createProduct(data: product)
        let id = productData!.id
        let _ = self.store.deleteProduct(id: productData!.id)

        // Order ignored if there's no processed item
        let order = OrderData(products: [OrderUnit(id: id, quantity: 2)])
        let result = store.createOrder(order: order)
        XCTAssertNil(result)
        orderIgnore.fulfill()

        // Order placed if there's at least one processed item
        let newProductData = store.createProduct(data: product)!
        let newId = newProductData.id
        let newOrder = OrderData(products: [OrderUnit(id: id, quantity: 2),
                                            OrderUnit(id: newId, quantity: 2)])
        let orderData = store.createOrder(order: newOrder)!
        XCTAssertEqual(orderData.totalItems, 2)
        XCTAssertEqual(orderData.totalPrice, 30.0)
        XCTAssertFalse(orderData.products[0].productExists)
        XCTAssertTrue(orderData.products[1].productExists)
        orderPlaced.fulfill()

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }

    func testOrderCancellation() {
        let orderCancelled = expectation(description: "Order cancelled")
        let product = self.createProductData()
        let productData = store.createProduct(data: product)
        let order = OrderData(products: [OrderUnit(id: productData!.id, quantity: 1)])
        let result = store.createOrder(order: order)
        XCTAssertNotNil(result)

        let orderData = store.cancelOrder(id: result!.id)
        XCTAssertNotNil(orderData)
        orderCancelled.fulfill()

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
}
