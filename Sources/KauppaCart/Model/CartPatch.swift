import Foundation

import KauppaCore

/// Removable/resettable stuff in cart.
public struct CartDeletionPatch: Mappable {
    /// Whether this cart should be reset.
    public var resetCart: Bool
    /// Remove the item at this index of the cart.
    public var removeItemAt: Int
}
