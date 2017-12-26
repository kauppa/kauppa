import Foundation

import KauppaCartModel

/// Data required for scheduling a pickup.
public struct PickupItems {
    /// List of products and their quantities to be picked up.
    public var items = [CartUnit]()

    /// Initialize an instance with empty list of items.
    public init() {}
}
