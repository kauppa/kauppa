import Foundation

import KauppaProductsModel

public protocol ProductsStore: ProductsPersisting, ProductsQuerying {
    //
}

public class ProductStore {     // NOTE: Will be replaced by protocol
    var product: Product

    public init() {
        self.product = Product(id: UUID(), createdOn: Date(), updatedAt: Date(), data: ProductData(title: "", subtitle: "", description: ""))
    }

    func createProduct(data: ProductData) -> Product? {
        let id = UUID()
        let date = Date()
        let data = data
        // if let variantId = data.variantId {
            //TODO: if self.getProductForId(id: variantId) == nil {
            //    data.variantId = nil
            //}
        // }

        let productData = Product(id: id,
                                  createdOn: date,
                                  updatedAt: date,
                                  data: data)
        //TODO: self.createNewProductWithId(id: id, product: productData)
        return productData
    }

    func getProduct(id: UUID) -> Product? {
        //TODO: return self.getProductForId(id: id)

        return nil
    }

    func deleteProduct(id: UUID) -> Product? {
        //TODO: return self.removeProductIfExists(id: id)

        return nil
    }

    func updateProduct(id: UUID, data: ProductPatch) -> Product? {
        //TODO: if var product = self.getProductForId(id: id) {
            if let title = data.title {
                product.data.title = title
            }

            if let subtitle = data.subtitle {
                product.data.subtitle = subtitle
            }

            if let description = data.description {
                product.data.description = description
            }

            if let size = data.size {
                if product.data.size == nil {
                    product.data.size = size
                } else {
                    if let length = size.length {
                        product.data.size!.length = length
                    }
                    if let width = size.width {
                        product.data.size!.width = width
                    }
                    if let height = size.height {
                        product.data.size!.height = height
                    }
                }
            }

            if let color = data.color {
                product.data.color = color
            }

            if let weight = data.weight {
                product.data.weight = weight
            }

            if let inventory = data.inventory {
                product.data.inventory = inventory
            }

            if let images = data.images {
                product.data.images = images
            }

            if let price = data.price {
                product.data.price = price
            }

            if let category = data.category {
                product.data.category = category
            }

            if let variantId = data.variantId {
                //TODO: if self.getProductForId(id: variantId) != nil && variantId != product.id {
                    product.data.variantId = variantId
                //}
            }

            product.updatedAt = Date()
            //TODO: self.updateProductForId(id: id, product: product)
            return product
        //} else {
        //    return nil
        //}
    }
}
