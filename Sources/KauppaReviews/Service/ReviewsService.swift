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

    public func getReviews(forProduct id: UUID) throws -> [Review] {
        return try repository.getReviews(forProduct: id)
    }

    public func updateReview(id: UUID, data: ReviewPatch) throws -> Review {
        var reviewData = try repository.getReviewData(forId: id)
        if let rating = data.rating {
            reviewData.rating = rating
        }

        if let comment = data.comment {
            if comment.isEmpty {
                throw ReviewsError.invalidComment
            }

            reviewData.comment = comment
        }

        return try repository.updateReviewData(id: id, data: reviewData)
    }
}
