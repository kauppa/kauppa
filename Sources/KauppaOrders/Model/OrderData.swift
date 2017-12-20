import Foundation

import KauppaCore

/// An order unit where the product is represented by its UUID.
public typealias OrderUnit = GenericOrderUnit<UUID>

/// Represents a product in order (along with the quantity required).
public struct GenericOrderUnit<P: Mappable>: Mappable {
    /// Product data
    public let product: P
    /// Desired quantity of this product (when this order was placed)
    public let quantity: UInt8
    /// Status of this order unit.
    ///
    /// `nil` indicates that none of the items in this unit
    /// has been fulfilled. It's either not delivered to the customer
    /// or the entire unit has been returned by the customer.
    public var status: OrderUnitStatus? = nil

    public init(product: P, quantity: UInt8) {
        self.product = product
        self.quantity = quantity
    }
}

/// Input data for placing an order
public struct OrderData: Mappable {
    /// ID of the user who placed this order.
    public let placedBy: UUID
    /// List of product IDs and their quantity (as an order unit).
    public let products: [OrderUnit]

    public init(placedBy id: UUID, products: [OrderUnit]) {
        self.placedBy = id
        self.products = products
    }
}
