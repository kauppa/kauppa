import Foundation
import XCTest

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
        let productData = ProductData(title: "", subtitle: "", description: "")
        let product = productsService.createProduct(data: productData)
        let ordersService = OrdersService(withRepository: repository,
                                          productsService: productsService)
        //
    }
}
