import Foundation

import KauppaCouponModel

/// Protocol to unify mutating and non-mutating methods.
public protocol CouponStorable: CouponPersisting, CouponQuerying {
    //
}
