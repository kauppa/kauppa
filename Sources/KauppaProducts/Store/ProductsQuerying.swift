import Foundation

import KauppaProductsModel

public protocol ProductsQuerying {
    func getProduct(id: UUID) -> Product?
}
