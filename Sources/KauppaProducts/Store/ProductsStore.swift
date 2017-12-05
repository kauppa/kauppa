import Foundation

import KauppaProductsModel

/// Protocol to unify mutating and non-mutating methods.
public protocol ProductsStore: ProductsPersisting, ProductsQuerying {
    //
}
