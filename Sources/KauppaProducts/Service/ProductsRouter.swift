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
        add(route: ProductsRoutes.createProduct) { request, response in
            let address = Address()     // TODO: Get address from request

            do {
                let data: ProductData = try request.getJSON()
                let product = try self.service.createProduct(data: data, from: address)
                response.respond(with: product, code: .ok)
            } catch {
                // log error and respond back to stream
            }
        }
    }
}
