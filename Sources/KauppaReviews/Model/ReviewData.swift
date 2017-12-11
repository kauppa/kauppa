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
    public var reviewFrom: UUID = UUID()

    /// ID of the product to which this review was posted.
    public var productId: UUID = UUID()

    /// Rating given for this product.
    public var rating: Rating = .worse

    /// Review comment for the product.
    public var comment: String = ""

    // FIXME: Add auth role

    public init() {}
}
