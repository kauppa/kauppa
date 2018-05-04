import KauppaCore

/// Status of a single ordered product (with quantity).
///
/// An example of how we should track product items:
///
/// - Customer orders `3` HDMI cables and `2` LED monitors.
/// - Order is successful, it's been delivered - so, the `fulfilledQuantity` for
/// HDMI cables is `3` and for the monitors, it's `2`
/// - Later, they choose to return `1` monitor and `1` cable.
/// - We now schedule a pickup. This changes the `pickupQuantity` to `1` for both monitors
/// and cables (indicating items queued for pickup). At this point, the `fulfilledQuantity`
/// still remains `3` and `2` for each products, because it's still with the customer.
/// This also makes sure that the customer cannot initiate another "return" with items exceeding
/// "fulfilled" and "pickup" quantities.
/// - Once we pickup the items, we get notification from the shipments service, and `pickupQuantity`
/// changes to `0` and `0` - with the values now moved to `refundableQuantity` (which is now `1` and `1`),
/// and reduced from `fulfilledQuantity` (which is now `2` and `1`).
/// - Now, `refundableQuantity` indicates the items that should be refunded to the customer.
/// Once an admin initiates a refund, this goes back to `0` and `0`
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

    /// Initialize an instance of this status object. The initial quantity
    /// is assumed to be fulfilled quantity of the item.
    ///
    /// - Parameters:
    ///   - for: The quantity of the associated item.
    public init(for quantity: UInt8) {
        fulfilledQuantity = quantity
    }
}
