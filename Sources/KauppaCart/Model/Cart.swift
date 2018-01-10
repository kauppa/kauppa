import Foundation

import KauppaCore
import KauppaGiftsModel

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
    /// Gift cards applied in this cart.
    public var giftCards = [UUID]()

    public init(withId id: UUID) {
        self.id = id
    }

    /// Reset this cart (called to clear the items once the cart has been checked out)
    public mutating func reset() {
        items = []
        currency = nil
        giftCards = []
    }
}
