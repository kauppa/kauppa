import Foundation

import KauppaProductsModel

public protocol ProductsServiceCallable {
    func createProduct(data: ProductData) -> Product?

    func getProduct(id: UUID) -> Product?

    func deleteProduct(id: UUID) -> Bool

    func updateProduct(id: UUID, data: ProductPatch) -> Product?
}
