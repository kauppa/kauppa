import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaProductsClient
import KauppaProductsModel

/// Router specific to the product service.
public class ProductsRouter<R: Routing>: ServiceRouter<R, ProductsRoutes> {
    let service: ProductsServiceCallable

    /// Initializes this router with a `Routing` object and
    /// a `ProductsServiceCallable` object.
    public init(with router: R, service: ProductsServiceCallable) {
        self.service = service
        super.init(with: router)
    }

    /// Overridden routes for products service.
    public override func initializeRoutes() {
        // TODO: Figure out how to use address for tax service.

        add(route: .getAttributes) { request, response in
            let attributes = try self.service.getAttributes()
            let data = MappableArray(for: attributes)
            try response.respondJSON(with: data)
        }

        add(route: .getCategories) { request, response in
            let categories = try self.service.getCategories()
            let data = MappableArray(for: categories)
            try response.respondJSON(with: data)
        }

        add(route: .createProduct) { request, response in
            guard let data: Product = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let product = try self.service.createProduct(with: data, from: nil)
            try response.respondJSON(with: product)
        }

        add(route: .getProduct) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidProductId
            }

            let product = try self.service.getProduct(for: id, from: nil)
            try response.respondJSON(with: product)
        }

        add(route: .deleteProduct) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidProductId
            }

            try self.service.deleteProduct(for: id)
            try response.respondJSON(with: ServiceStatusMessage())
        }

        add(route: .updateProduct) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidProductId
            }

            guard let data: ProductPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let product = try self.service.updateProduct(for: id, with: data, from: nil)
            try response.respondJSON(with: product)
        }

        add(route: .getAllProducts) { request, response in
            let products = try self.service.getProducts()
            let data = MappableArray(for: products)
            try response.respondJSON(with: data)
        }

        add(route: .addProductProperty) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidProductId
            }

            guard let data: ProductPropertyAdditionPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let product = try self.service.addProductProperty(for: id, with: data, from: nil)
            try response.respondJSON(with: product)
        }

        add(route: .deleteProductProperty) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidProductId
            }

            guard let data: ProductPropertyDeletionPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let product = try self.service.deleteProductProperty(for: id, with: data, from: nil)
            try response.respondJSON(with: product)
        }

        add(route: .createCollection) { request, response in
            guard let data: ProductCollectionData = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let collection = try self.service.createCollection(with: data)
            try response.respondJSON(with: collection)
        }

        add(route: .getCollection) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidCollectionId
            }

            let collection = try self.service.getCollection(for: id)
            try response.respondJSON(with: collection)
        }

        add(route: .updateCollection) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidCollectionId
            }

            guard let data: ProductCollectionPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let collection = try self.service.updateCollection(for: id, with: data)
            try response.respondJSON(with: collection)
        }

        add(route: .deleteCollection) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidCollectionId
            }

            try self.service.deleteCollection(for: id)
            try response.respondJSON(with: ServiceStatusMessage())
        }

        add(route: .addCollectionProduct) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidCollectionId
            }

            guard let data: ProductCollectionItemPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let collection = try self.service.addProduct(to: id, using: data)
            try response.respondJSON(with: collection)
        }

        add(route: .removeCollectionProduct) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidCollectionId
            }

            guard let data: ProductCollectionItemPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let collection = try self.service.removeProduct(from: id, using: data)
            try response.respondJSON(with: collection)
        }
    }
}
