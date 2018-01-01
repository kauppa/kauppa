import KauppaCore

/// Route identifiers for the products service. Each variant is associated with a route,
/// and it corresponds to a service call.
public enum ProductsRoutes: UInt8 {
    case getAttributes
    case getCategories
    case createProduct
    case getProduct
    case getAllProducts
    case deleteProduct
    case updateProduct
}

extension ProductsRoutes: RouteRepresentable {
    public var route: Route {
        switch self {
            case .getAttributes:
                return Route(url: "/attributes",    method: .get)
            case .getCategories:
                return Route(url: "/categories",    method: .get)
            case .createProduct:
                return Route(url: "/products",      method: .post)
            case .getProduct:
                return Route(url: "/products/:id",  method: .get)
            case .deleteProduct:
                return Route(url: "/products/:id",  method: .delete)
            case .updateProduct:
                return Route(url: "/products/:id",  method: .put)

            // FIXME: No, no, no! This shouldn't be here! Remove this ASAP
            case .getAllProducts:
                return Route(url: "/products",      method: .get)
        }
    }
}
