import Foundation

import KauppaProductsModel

public protocol ProductsPersisting {
    func createNewProduct(productData: Product) throws -> ()

    func deleteProduct(id: UUID) throws -> ()

    func updateProduct(productData: Product) throws -> ()
}
