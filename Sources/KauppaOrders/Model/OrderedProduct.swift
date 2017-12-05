import Foundation

import KauppaCore

public struct OrderedProduct: Encodable {
    /// Product ID
    public let id: UUID?
    /// The number of items that have been processed
    /// for the given quantity.
    public let processedItems: UInt8

    public init(id: UUID?, processedItems: UInt8) {
        self.id = id
        self.processedItems = processedItems
    }
}
