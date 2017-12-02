import Foundation

import KauppaProductsModel

public protocol ProductsPersisting {
    func createNewProduct(productData: Product)

    func deleteProduct(id: UUID) -> Bool

    func updateProduct(productData: Product)
}
