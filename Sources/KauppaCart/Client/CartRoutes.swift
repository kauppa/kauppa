import KauppaCore

/// Route identifiers for the cart service. Each variant is associated with a route,
/// and it corresponds to a service call.
public enum CartRoutes: UInt8 {
    case addItemToCart
    case removeItemFromCart
    case getCart
    case replaceCartItems
    case applyCoupon
    case placeOrder
}

extension CartRoutes: RouteRepresentable {
    public var route: Route {
        switch self {
            case .addItemToCart:
                return Route(url: "/cart/:id/items",        method: .post)
            case .removeItemFromCart:
                return Route(url: "/cart/:id/items/:item",  method: .delete)
            case .getCart:
                return Route(url: "/cart/:id",              method: .get)
            case .replaceCartItems:
                return Route(url: "/cart/:id/items",        method: .put)
            case .applyCoupon:
                return Route(url: "/cart/:id/coupons",      method: .post)
            case .placeOrder:
                return Route(url: "/cart/:id/checkout",     method: .post)
        }
    }
}
