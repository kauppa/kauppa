import Foundation

import KauppaCore

/// Cart that exists in repository and store.
public struct Cart: Mappable {
    /// Unique identifier for this cart.
    public let id: UUID
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// Stuff in the cart
    public var data: CartData

    public init(id: UUID, createdOn: Date, updatedAt: Date, data: CartData) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = updatedAt
        self.data = data
    }
}
