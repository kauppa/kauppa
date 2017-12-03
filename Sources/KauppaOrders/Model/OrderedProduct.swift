import Foundation

import KauppaCore

public struct OrderedProduct: Encodable {
    public let id: UUID?
    public let processedItems: UInt8

    public init(id: UUID?, processedItems: UInt8) {
        self.id = id
        self.processedItems = processedItems
    }
}
