import KauppaCore

/// Status of a single ordered product (with quantity).
public struct OrderUnitStatus: Mappable {
    /// Quantity sent to the customer.
    public var fulfilledQuantity: UInt8
    /// Quantity that's been scheduled for pickup.
    public var pickupQuantity: UInt8 = 0
    /// Quantity returned by the customer. This represents the items
    /// that have been picked up. They're refundable.
    public var refundableQuantity: UInt8 = 0
    /// Status of this ordered unit.
    public var fulfillment: FulfillmentStatus? = nil

    public init(quantity: UInt8) {
        fulfilledQuantity = quantity
    }

    /// Number of items that have been fulfilled and hasn't been scheduled for pickup.
    // FIXME: May need a better name?
    public func untouchedItems() -> UInt8 {
        return fulfilledQuantity - pickupQuantity
    }
}
