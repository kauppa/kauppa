import Foundation

import KauppaCore

public struct OrderUnit: Mappable {
    /// Product ID
    public let id: UUID
    /// Quantity of this product required
    public let quantity: UInt8
}
