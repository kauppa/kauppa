
///
public enum ServiceStatus: String, Mappable {
    case ok
    case error
}

///
public struct ServiceStatusMessage: Mappable {
    ///
    public let status: ServiceStatus
    ///
    public var code: UInt16? = nil

    public init(error: ServiceError? = nil) {
        status = error == nil ? .ok : .error
        if let error = error {
            code = error.rawValue
        }
    }
}
