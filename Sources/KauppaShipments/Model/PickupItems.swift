import Foundation

import KauppaOrdersModel

/// Data required for scheduling a pickup.
public struct PickupItems {
    /// List of products and their quantities to be picked up.
    public var items = [OrderUnit]()

    public init() {}
}
