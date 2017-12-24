import Foundation

import KauppaCore
import KauppaProductsModel

/// Methods that mutate the underlying store with information.
public protocol ProductsPersisting: Persisting {
    /// Create a new product with the product information from repository.
    func createNewProduct(with data: Product) throws -> ()

    /// Delete a product corresponding to an ID.
    func deleteProduct(for id: UUID) throws -> ()

    /// Update a product with the product information. ID will be obtained
    /// from the data.
    func updateProduct(with data: Product) throws -> ()

    /// Create an attribute using the given data.
    func createAttribute(with data: Attribute) throws -> ()

    /// Create a new collection with information from the repository.
    func createNewCollection(with data: ProductCollection) throws -> ()

    /// Update an existing collection with data from repository.
    func updateCollection(with data: ProductCollection) throws -> ()

    /// Delete a collection corresponding to an ID.
    func deleteCollection(for id: UUID) throws -> ()
}
