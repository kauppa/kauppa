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

    public init(withData data: GiftCardData) {
        let id = UUID()
        let date = Date()
        self.id = id
        self.createdOn = date
        self.updatedAt = date
        self.data = data
    }
}
