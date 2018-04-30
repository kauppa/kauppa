import Foundation

import KauppaCore
import KauppaCartModel

/// An order unit where the product is represented by its UUID.
public typealias OrderUnit = GenericOrderUnit<UUID>

/// Represents a product in order (along with the quantity required).
public struct GenericOrderUnit<P: Mappable>: Mappable {
    /// Represents a  cart item. `CartUnit` has the price and tax data
    /// in addition to the product and quantity. This is useful in orders,
    /// because we'd want to calculate the tax and prices again.
    public var item: GenericCartUnit<P>
    /// Status of this order unit.
    public var status: OrderUnitStatus? = nil

    /// Initialize this unit with a product and quantity.
    ///
    /// - Parameters:
    ///   - for: The product represented by this unit.
    ///   - with: The quantity of the product item.
    public init(for product: P, with quantity: UInt8) {
        item = GenericCartUnit(for: product, with: quantity)
    }

    /// `nil` indicates that none of the items in this unit
    /// has been fulfilled. It's either not delivered to the customer
    /// or the entire unit has been returned by the customer.
    /// The other case, however represents that some (or all) of the
    /// items have reached the customer.
    public var hasFulfillment: Bool {
        return self.status != nil
    }

    /// Resets the service-settable properties in this object.
    public mutating func resetInternalProperties() {
        item.resetInternalProperties()
        status = nil
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
