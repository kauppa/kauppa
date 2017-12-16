import KauppaCore

/// Route identifiers for the products service. Each variant is associated with a route,
/// and it corresponds to a service call.
public enum ProductsRoutes: UInt8 {
    case createProduct
    case getProduct
    case deleteProduct
    case updateProduct
    case addProductProperty
    case deleteProductProperty
}

extension ProductsRoutes: RouteRepresentable {
    public var route: Route {
        switch self {
            case .createProduct:
                return Route(url: "/products",      method: .post)
            case .getProduct:
                return Route(url: "/products/:id",  method: .get)
            case .deleteProduct:
                return Route(url: "/products/:id",  method: .delete)
            case .updateProduct:
                return Route(url: "/products/:id",  method: .put)
            case .addProductProperty:
                return Route(url: "/products/:id",  method: .post)
            case .deleteProductProperty:
                return Route(url: "/products/:id",  method: .put)
        }
    }
}
