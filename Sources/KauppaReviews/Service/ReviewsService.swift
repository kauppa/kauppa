import Foundation

import KauppaCore
import KauppaAccountsClient
import KauppaProductsClient
import KauppaReviewsClient
import KauppaReviewsModel
import KauppaReviewsRepository

/// Public API for review comments on different entities.
public class ReviewsService {
    let repository: ReviewsRepository
    let productsService: ProductsServiceCallable
    let accountsService: AccountsServiceCallable

    /// Initializes a new `ReviewsService` instance with a
    /// repository, accounts and products service.
    public init(withRepository repository: ReviewsRepository,
                productsService: ProductsServiceCallable,
                accountsService: AccountsServiceCallable)
    {
        self.repository = repository
        self.productsService = productsService
        self.accountsService = accountsService
    }
}

extension ReviewsService: ReviewsServiceCallable {
    public func createReview(withData data: ReviewData) throws -> Review {
        if data.comment.isEmpty {
            throw ReviewsError.invalidComment
        }

        let _ = try productsService.getProduct(id: data.productId)
        let _ = try accountsService.getAccount(id: data.createdBy)

        return try repository.createReview(data: data)
    }
}
