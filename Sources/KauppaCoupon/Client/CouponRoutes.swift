import KauppaCore

/// Route identifiers for the coupon service. Each variant is associated with a route,
/// and it corresponds to a service call.
public enum CouponRoutes: UInt8 {
    case createCoupon
    case getCoupon
    case updateCoupon
}

extension CouponRoutes: RouteRepresentable {
    public var route: Route {
        switch self {
            case .createCoupon:
                return Route(url: "/coupons",       method: .post)
            case .getCoupon:
                return Route(url: "/coupons/:id",   method: .get)
            case .updateCoupon:
                return Route(url: "/coupons/:id",   method: .put)
        }
    }
}
