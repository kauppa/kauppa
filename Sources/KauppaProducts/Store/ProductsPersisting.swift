import Foundation

import KauppaProductsModel

public protocol ProductsPersisting {
    func createNewProduct(id: UUID, product: Product)

    func deleteProduct(id: UUID) -> Bool
}
