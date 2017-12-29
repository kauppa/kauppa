import KauppaCore

/// Route identifiers for the accounts service. Each variant is associated with a route,
/// and it corresponds to a service call.
public enum AccountsRoutes: UInt8 {
    case createAccount
    case verifyEmail
    case getAccount
    case deleteAccount
    case updateAccount
}

extension AccountsRoutes: RouteRepresentable {
    public var route: Route {
        switch self {
            case .createAccount:
                return Route(url: "/accounts",      method: .post)
            case .verifyEmail:
                return Route(url: "/emails",        method: .post)
            case .getAccount:
                return Route(url: "/accounts/:id",  method: .get)
            case .deleteAccount:
                return Route(url: "/accounts/:id",  method: .delete)
            case .updateAccount:
                return Route(url: "/accounts/:id",  method: .put)
        }
    }
}
