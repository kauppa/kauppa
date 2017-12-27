
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

    public init(_ status: ServiceStatus, error: ServiceError? = nil) {
        self.status = status
        if let error = error {
            code = error.rawValue
        }
    }
}
