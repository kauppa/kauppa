import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaProductsModel

/// HTTP client for the products service.
public class ProductsServiceClient<C: ClientCallable>: ServiceClient<C, ProductsRoutes>, ProductsServiceCallable {
    public func getAttributes() throws -> [Attribute] {
        let client = try createClient(for: .getAttributes)
        let data: MappableArray<Attribute> = try requestJSON(with: client)
        return data.inner
    }

    public func getCategories() throws -> [Category] {
        let client = try createClient(for: .getCategories)
        let data: MappableArray<Category> = try requestJSON(with: client)
        return data.inner
    }

    public func createProduct(with data: Product, from address: Address?) throws -> Product {
        let client = try createClient(for: .createProduct)
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func getProduct(for id: UUID, from address: Address?) throws -> Product {
        let client = try createClient(for: .getProduct, with: ["id": id])
        return try requestJSON(with: client)
    }

    // FIXME: Remove this.
    public func getProducts() throws -> [Product] {
        let client = try createClient(for: .getAllProducts)
        let data: MappableArray<Product> = try requestJSON(with: client)
        return data.inner
    }

    public func deleteProduct(for id: UUID) throws -> () {
        let client = try createClient(for: .deleteProduct, with: ["id": id])
        let _: ServiceStatusMessage = try requestJSON(with: client)
    }

    public func updateProduct(for id: UUID, with data: ProductPatch,
                              from address: Address?) throws -> Product
    {
        let client = try createClient(for: .deleteProduct, with: ["id": id])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func addProductProperty(for id: UUID, with data: ProductPropertyAdditionPatch,
                                   from address: Address?) throws -> Product
    {
        let client = try createClient(for: .addProductProperty, with: ["id": id])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func deleteProductProperty(for id: UUID, with data: ProductPropertyDeletionPatch,
                                      from address: Address?) throws -> Product
    {
        let client = try createClient(for: .deleteProductProperty, with: ["id": id])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func createCollection(with data: ProductCollectionData) throws -> ProductCollection {
        let client = try createClient(for: .createCollection)
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func getCollection(for id: UUID) throws -> ProductCollection {
        let client = try createClient(for: .getCollection, with: ["id": id])
        return try requestJSON(with: client)
    }

    public func updateCollection(for id: UUID, with data: ProductCollectionPatch) throws -> ProductCollection {
        let client = try createClient(for: .updateCollection, with: ["id": id])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func deleteCollection(for id: UUID) throws -> () {
        let client = try createClient(for: .deleteCollection, with: ["id": id])
        let _: ServiceStatusMessage = try requestJSON(with: client)
    }

    public func addProduct(to id: UUID, using data: ProductCollectionItemPatch) throws -> ProductCollection {
        let client = try createClient(for: .addCollectionProduct, with: ["id": id])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func removeProduct(from id: UUID, using data: ProductCollectionItemPatch) throws -> ProductCollection {
        let client = try createClient(for: .removeCollectionProduct, with: ["id": id])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }
}
