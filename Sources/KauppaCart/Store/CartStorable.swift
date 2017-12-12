import Foundation

import KauppaCartModel

/// Protocol to unify mutating and non-mutating methods.
public protocol CartStorable: CartPersisting, CartQuerying {
    //
}
