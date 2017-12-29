import Foundation

import KauppaGiftsModel

/// Protocol to unify mutating and non-mutating methods.
public protocol GiftsStorable: GiftsPersisting, GiftsQuerying {
    //
}
