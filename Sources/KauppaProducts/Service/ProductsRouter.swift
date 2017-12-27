import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaProductsClient
import KauppaProductsModel

/// Router specific to the product service.
public class ProductsRouter<R: Routing>: ServiceRouter<R> {
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

        add(route: ProductsRoutes.createProduct) { request, response in
            guard let data: ProductData = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let product = try self.service.createProduct(with: data, from: nil)
            response.respond(with: product, code: .ok)
        }

        add(route: ProductsRoutes.getProduct) { request, response in
            let id: UUID = request.getParameter(for: "id")!
            let product = try self.service.getProduct(for: id, from: nil)
            response.respond(with: product, code: .ok)
        }
    }
}
