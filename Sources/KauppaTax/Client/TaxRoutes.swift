import KauppaCore

/// Route identifiers for the tax service. Each variant is associated with a route,
/// and it corresponds to a service call.
public enum TaxRoutes: UInt8 {
    case getTaxRate
    case createCountry
    case updateCountry
    case deleteCountry
    case addRegion
    case updateRegion
    case deleteRegion
}

extension TaxRoutes: RouteRepresentable {
    public var route: Route {
        switch self {
            case .getTaxRate:
                return Route(url: "/rate",                  method: .get)
            case .createCountry:
                return Route(url: "/countries",             method: .post)
            case .updateCountry:
                return Route(url: "/countries/:id",         method: .put)
            case .deleteCountry:
                return Route(url: "/countries/:id",         method: .delete)
            case .addRegion:
                return Route(url: "/countries/:id/regions", method: .post)
            case .updateRegion:
                return Route(url: "/regions/:id",           method: .put)
            case .deleteRegion:
                return Route(url: "/regions/:id",           method: .delete)
        }
    }
}
