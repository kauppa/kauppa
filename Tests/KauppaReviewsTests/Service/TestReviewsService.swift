import Foundation
import XCTest

import KauppaCore
import KauppaAccountsModel
import KauppaProductsModel
@testable import KauppaReviewsModel
@testable import KauppaReviewsRepository
@testable import KauppaReviewsService

class TestReviewsService: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()

    static var allTests: [(String, (TestReviewsService) -> () throws -> Void)] {
        return [
            ("Test review creation", testReviewCreation),
            ("Test invalid review comment", testInvalidComment),
            ("Test invalid product reference", testInvalidProduct),
            ("Test invalid account", testInvalidAccount),
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

    func testReviewCreation() {
        let store = TestStore()
        let repository = ReviewsRepository(withStore: store)
        let productData = ProductData(title: "", subtitle: "", description: "")
        let product = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let service = ReviewsService(withRepository: repository,
                                     productsService: productsService,
                                     accountsService: accountsService)
        var reviewData = ReviewData()
        reviewData.productId = product.id
        reviewData.createdBy = account.id
        reviewData.comment = "You suck!"

        let data = try! service.createReview(withData: reviewData)
        XCTAssertEqual(data.createdOn, data.updatedAt)
    }

    func testInvalidComment() {
        let store = TestStore()
        let repository = ReviewsRepository(withStore: store)
        let service = ReviewsService(withRepository: repository,
                                     productsService: productsService,
                                     accountsService: accountsService)
        let reviewData = ReviewData()   // comment is checked first
        do {
            let _ = try service.createReview(withData: reviewData)
            XCTFail()
        } catch let err {
            XCTAssertTrue(err as! ReviewsError == ReviewsError.invalidComment)
        }
    }

    func testInvalidProduct() {
        let store = TestStore()
        let repository = ReviewsRepository(withStore: store)

        let service = ReviewsService(withRepository: repository,
                                     productsService: productsService,
                                     accountsService: accountsService)
        var reviewData = ReviewData()
        reviewData.comment = "You suck!"    // product is checked next to comment
        do {
            let _ = try service.createReview(withData: reviewData)
            XCTFail()
        } catch let err {
            XCTAssertTrue(err as! ProductsError == ProductsError.invalidProduct)
        }
    }

    func testInvalidAccount() {
        let store = TestStore()
        let repository = ReviewsRepository(withStore: store)
        let productData = ProductData(title: "", subtitle: "", description: "")
        let product = try! productsService.createProduct(data: productData)

        let service = ReviewsService(withRepository: repository,
                                     productsService: productsService,
                                     accountsService: accountsService)
        var reviewData = ReviewData()
        reviewData.productId = product.id   // add product ID and ignore account
        reviewData.comment = "You suck!"
        do {
            let _ = try service.createReview(withData: reviewData)
            XCTFail()
        } catch let err {
            XCTAssertTrue(err as! AccountsError == AccountsError.invalidAccount)
        }
    }
}
