import Foundation

import KauppaProductsModel

/// Protocol to unify mutating and non-mutating methods.
public protocol ProductsStorable: ProductsPersisting, ProductsQuerying {
    //
}
