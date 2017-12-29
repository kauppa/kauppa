import Foundation

import KauppaShipmentsModel

/// Protocol to unify mutating and non-mutating methods.
public protocol ShipmentsStorable: ShipmentsPersisting, ShipmentsQuerying {
    //
}
