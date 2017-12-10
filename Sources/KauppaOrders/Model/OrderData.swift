import Foundation

import KauppaCore

/// Input data for placing an order
public struct OrderData: Mappable {
    /// ID of the user who placed this order.
    public let placedBy: UUID
    /// List of product IDs and their quantity (as an order unit).
    public let products: [OrderUnit]
}
