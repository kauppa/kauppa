import KauppaCore

/// Route identifiers for the shipments service. Each variant is associated with a route,
/// and it corresponds to a service call.
public enum ShipmentsRoutes: UInt8 {
    case createShipment
    case notifyShipping
    case notifyDelivery
    case schedulePickup
    case completePickup
}

extension ShipmentsRoutes: RouteRepresentable {
    public var route: Route {
        // FIXME: The routes and the corresponding service calls are ick'ish. Rethink.
        switch self {
            case .createShipment:
                return Route(url: "/shipments/:order/create",   method: .post)
            case .notifyShipping:
                return Route(url: "/shipments/:id/shipped",     method: .put)
            case .notifyDelivery:
                return Route(url: "/shipments/:id/delivered",   method: .put)
            case .schedulePickup:
                return Route(url: "/shipments/:order/pickup",   method: .put)
            case .completePickup:
                return Route(url: "/shipments/:id/picked",      method: .put)
        }
    }
}
