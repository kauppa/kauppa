import Foundation

import KauppaCore
import KauppaProductsModel

/// A no-op store for products which doesn't support data persistence/querying.
/// This way, the repository takes care of all service requests by providing
/// in-memory data.
public class ProductsNoOpStore: ProductsStorable {
    public init() {}

    public func createNewProduct(with data: Product) throws -> () {}

    public func getProduct(for id: UUID) throws -> Product {
        throw ServiceError.invalidProductId
    }

    public func deleteProduct(for id: UUID) throws -> () {}

    public func updateProduct(with data: Product) throws -> () {}

    public func createNewCollection(with data: ProductCollection) throws -> () {}

    public func getCollection(for id: UUID) throws -> ProductCollection {
        throw ServiceError.invalidCollectionId
    }

    public func updateCollection(with data: ProductCollection) throws -> () {}

    public func deleteCollection(for id: UUID) throws -> () {}

    public func createAttribute(with data: Attribute) throws -> () {}

    public func getAttribute(for id: UUID) throws -> Attribute {
        throw ServiceError.invalidAttributeId
    }

    public func createCategory(with data: Category) throws -> () {}

    public func getCategory(for id: UUID) throws -> Category {
        throw ServiceError.invalidCategoryId
    }

    public func getCategory(for name: String) throws -> Category {
        throw ServiceError.invalidCategoryName
    }

    public func getCategories() throws -> [Category] {
        return []
    }
}
