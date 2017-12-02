import Foundation

import KauppaProductsModel

public protocol ProductsPersisting {
    func createNewProduct(id: UUID, product: Product)
}
