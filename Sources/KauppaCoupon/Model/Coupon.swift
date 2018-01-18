import Foundation

import KauppaCore

/// Coupon data that exists in repository and store.
public struct Coupon: Mappable {
    /// Unique identifier for this card.
    public let id: UUID
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// Data associated with the gift card.
    public var data: CouponData

    public init(with data: CouponData) {
        let id = UUID()
        let date = Date()
        self.id = id
        self.createdOn = date
        self.updatedAt = date
        self.data = data
    }
}
