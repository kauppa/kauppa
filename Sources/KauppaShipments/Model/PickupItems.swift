import Foundation

import KauppaCore
import KauppaOrdersModel

/// Data required for scheduling a pickup.
public struct PickupItems: Mappable {
    /// List of products and their quantities to be picked up.
    public var items = [OrderUnit]()

    /// Initialize an instance with empty list of items.
    public init() {}
}
