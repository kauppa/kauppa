import Foundation

protocol ProductStore {
    func createProduct(data: ProductData) -> Product?
    func getProduct(id: UUID) -> Product?
    func deleteProduct(id: UUID) -> Product?
    func updateProduct(id: UUID, data: ProductPatch) -> Product?
}

extension MemoryStore: ProductStore {
    func createProduct(data: ProductData) -> Product? {
        let id = UUID()
        let date = Date()
        var data = data
        if let variantId = data.variantId {
            if self.getProductForId(id: variantId) == nil {
                data.variantId = nil
            }
        }

        let productData = Product(id: id,
                                  createdOn: date,
                                  updatedAt: date,
                                  data: data)
        self.createNewProductWithId(id: id, product: productData)
        return productData
    }

    func getProduct(id: UUID) -> Product? {
        return self.getProductForId(id: id)
    }

    func deleteProduct(id: UUID) -> Product? {
        return self.removeProductIfExists(id: id)
    }

    func updateProduct(id: UUID, data: ProductPatch) -> Product? {
        if var product = self.getProductForId(id: id) {
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
                if self.getProductForId(id: variantId) != nil && variantId != product.id {
                    product.data.variantId = variantId
                }
            }

            product.updatedAt = Date()
            self.updateProductForId(id: id, product: product)
            return product
        } else {
            return nil
        }
    }
}
