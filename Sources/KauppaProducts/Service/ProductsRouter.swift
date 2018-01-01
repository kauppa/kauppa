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
            response.respondJSON(with: data, code: .ok)
        }

        add(route: .getCategories) { request, response in
            let categories = try self.service.getCategories()
            let data = MappableArray(for: categories)
            response.respondJSON(with: data, code: .ok)
        }

        add(route: .createProduct) { request, response in
            guard let data: Product = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let product = try self.service.createProduct(with: data, from: nil)
            response.respondJSON(with: product, code: .ok)
        }

        add(route: .getProduct) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidProductId
            }

            let product = try self.service.getProduct(for: id, from: nil)
            response.respondJSON(with: product, code: .ok)
        }

        add(route: .deleteProduct) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidProductId
            }

            try self.service.deleteProduct(for: id)
            response.respondJSON(with: ServiceStatusMessage(), code: .ok)
        }

        add(route: .updateProduct) { request, response in
            guard let data: ProductPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidProductId
            }

            let product = try self.service.updateProduct(for: id, with: data, from: nil)
            response.respondJSON(with: product, code: .ok)
        }

        add(route: .getAllProducts) { request, response in
            let products = try self.service.getProducts()
            let data = MappableArray(for: products)
            response.respondJSON(with: data, code: .ok)
        }
    }
}
