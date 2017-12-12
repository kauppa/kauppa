import Foundation

import KauppaCore

/// A cart unit represents a product with the specified quantity.
public struct CartUnit: Mappable {
    /// Product ID
    public let productId: UUID
    /// Required quantity of this product
    public let quantity: UInt8

    public init(id: UUID, quantity: UInt8) {
        self.productId = id
        self.quantity = quantity
    }
}
