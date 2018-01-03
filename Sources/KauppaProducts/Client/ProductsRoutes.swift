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
    case addProductProperty
    case deleteProductProperty
    case createCollection
    case getCollection
    case updateCollection
    case deleteCollection
    case addCollectionProduct
    case removeCollectionProduct
}

extension ProductsRoutes: RouteRepresentable {
    public var route: Route {
        switch self {
            case .getAttributes:
                return Route(url: "/attributes",                method: .get)
            case .getCategories:
                return Route(url: "/categories",                method: .get)
            case .createProduct:
                return Route(url: "/products",                  method: .post)
            case .getProduct:
                return Route(url: "/products/:id",              method: .get)
            case .deleteProduct:
                return Route(url: "/products/:id",              method: .delete)
            case .updateProduct:
                return Route(url: "/products/:id",              method: .put)
            case .addProductProperty:
                return Route(url: "/products/:id/properties",   method: .post)
            case .deleteProductProperty:
                return Route(url: "/products/:id/properties",   method: .delete)
            case .createCollection:
                return Route(url: "/collections",               method: .post)
            case .getCollection:
                return Route(url: "/collections/:id",           method: .get)
            case .updateCollection:
                return Route(url: "/collections/:id",           method: .put)
            case .deleteCollection:
                return Route(url: "/collections/:id",           method: .delete)
            case .addCollectionProduct:
                return Route(url: "/collections/:id/products",  method: .post)
            case .removeCollectionProduct:
                return Route(url: "/collections/:id/products",  method: .delete)

            // FIXME: No, no, no! This shouldn't be here! Remove this ASAP
            case .getAllProducts:
                return Route(url: "/products",                  method: .get)
        }
    }
}
