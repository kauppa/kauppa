import Foundation

import KauppaCore

/// Cart that exists in repository and store.
public struct Cart: Mappable {
    /// Unique identifier for this cart.
    public let id: UUID
    /// Last updated timestamp
    public var updatedAt = Date()
    /// Stuff in the cart
    public var items: [CartUnit] = []
    /// Unit of currency used in this cart.
    public var currency: Currency? = nil

    public init(withId id: UUID) {
        self.id = id
    }
}
