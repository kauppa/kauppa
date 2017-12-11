import Foundation

import KauppaCore

public enum Rating: UInt8, Mappable {
    case worse = 1
    case bad   = 2
    case okay  = 3
    case good  = 4
    case best  = 5
}

/// User-supplied data for a review.
public struct ReviewData: Mappable {
    /// Account which posted this review
    public let reviewFrom: UUID

    /// ID of the product to which this review was posted.
    public let productId: UUID

    /// Rating given for this product.
    public let rating: Rating

    /// Review comment for the product.
    public let comment: String
}
