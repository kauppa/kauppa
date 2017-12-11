import Foundation

import KauppaReviewsModel

/// Protocol to unify mutating and non-mutating methods.
public protocol ReviewsStorable: ReviewsPersisting, ReviewsQuerying {
    //
}
