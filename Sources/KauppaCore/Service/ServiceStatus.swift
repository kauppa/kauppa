
/// Status of the service response (success or failure).
public enum ServiceStatus: String, Mappable {
    case ok
    case error
}

/// Object returned by the service to indicate success or failures.
/// In case of service calls that may not return anything, this object
/// is returned in the HTTP response.
public struct ServiceStatusMessage: Mappable {
    /// Status of the service response (success or failure).
    public let status: ServiceStatus
    /// Error code (if it was an error).
    public var code: UInt16? = nil

    /// Initialize an instance with an (optional) error. If no parameters were
    /// given, then this defaults to success. Otherwise, the code of the given
    /// `ServiceError` is set and error is set for the status.
    public init(error: ServiceError? = nil) {
        status = error == nil ? .ok : .error
        if let error = error {
            code = error.rawValue
        }
    }
}
