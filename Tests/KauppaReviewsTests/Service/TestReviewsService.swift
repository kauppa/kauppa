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
            ("Test review update", testReviewUpdate),
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

    func testReviewUpdate() {
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
        XCTAssertEqual(data.data.rating, .worse)
        XCTAssertEqual(data.data.comment, "You suck!")
        XCTAssertEqual(data.createdOn, data.updatedAt)

        var patch = ReviewPatch()
        patch.rating = .good    // change rating
        let update1 = try! service.updateReview(id: data.id, data: patch)
        XCTAssertEqual(update1.data.rating, .good)
        XCTAssertTrue(update1.createdOn != update1.updatedAt)

        patch.comment = "This is amazing!"      // change comment
        let update2 = try! service.updateReview(id: data.id, data: patch)
        XCTAssertEqual(update2.data.comment, "This is amazing!")

        patch.comment = ""      // invalid comment
        do {
            let _ = try service.updateReview(id: data.id, data: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ReviewsError, ReviewsError.invalidComment)
        }
    }
}
