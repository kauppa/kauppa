import KauppaCore

/// Route identifiers for the orderss service. Each variant is associated with a route,
/// and it corresponds to a service call.
public enum OrdersRoutes: UInt8 {
    case createOrder
    case getOrder
    case cancelOrder
    case returnOrder
    case updateShipment
    case initiateRefund
    case deleteOrder
    case getAllOrders
}

extension OrdersRoutes: RouteRepresentable {
    public var route: Route {
        switch self {
            case .createOrder:
                return Route(url: "/orders",                method: .post)
            case .getOrder:
                return Route(url: "/orders/:id",            method: .get)
            case .cancelOrder:
                return Route(url: "/orders/:id/cancel",     method: .put)
            case .returnOrder:
                return Route(url: "/orders/:id/returns",    method: .post)
            case .updateShipment:
                return Route(url: "/orders/:id/shipments",  method: .post)
            case .initiateRefund:
                return Route(url: "/orders/:id/refunds",    method: .post)
            case .deleteOrder:
                return Route(url: "/orders/:id",            method: .delete)

            // FIXME: This shouldn't be here! Remove this ASAP
            case .getAllOrders:
                return Route(url: "/orders",                method: .get)
        }
    }
}
