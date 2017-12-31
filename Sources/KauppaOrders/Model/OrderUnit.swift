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
    public var status: OrderUnitStatus? = nil

    public init(product: P, quantity: UInt8) {
        self.product = product
        self.quantity = quantity
    }

    /// `nil` indicates that none of the items in this unit
    /// has been fulfilled. It's either not delivered to the customer
    /// or the entire unit has been returned by the customer.
    /// The other case, however represents that some (or all) of the
    /// items have reached the customer.
    public var hasFulfillment: Bool {
        return self.status != nil
    }

    /// Number of items that have been fulfilled and hasn't been scheduled for pickup.
    // FIXME: May need a better name?
    public func untouchedItems() -> UInt8 {
        if let unitStatus = status {
            return unitStatus.fulfilledQuantity - unitStatus.pickupQuantity
        }

        return 0
    }
}
