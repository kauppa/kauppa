import Foundation

import KauppaCore

/// Gift card data that exists in repository and store.
public struct GiftCard: Mappable {
    /// Unique identifier for this card.
    public let id: UUID
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// Data associated with the gift card.
    public var data: GiftCardData

    public init(id: UUID, createdOn: Date, updatedAt: Date, data: GiftCardData) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = updatedAt
        self.data = data
    }
}
