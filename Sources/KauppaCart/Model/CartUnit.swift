import Foundation

import KauppaCore

/// A cart unit represents a product with the specified quantity.
public struct CartUnit: Mappable {
    /// Product ID
    public var productId: UUID
    /// Required quantity of this product
    public var quantity: UInt8

    public init(id: UUID, quantity: UInt8) {
        self.productId = id
        self.quantity = quantity
    }
}
