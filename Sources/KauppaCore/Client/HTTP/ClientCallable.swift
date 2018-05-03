import Foundation

/// Protocol indicating that the implementor is a HTTP client.
public protocol ClientCallable {
    /// The response returned by this client after making the request.
    associatedtype Response: ClientResponse

    /// Initialize this client with a method and URL.
    ///
    /// - Parameters:
    ///   - with: The `HTTPMethod` for this request.
    ///   - on: The request `URL`.
    init(with method: HTTPMethod, on url: URL)

    /// Set the given key/value pair for the request's header.
    ///
    /// - Parameters:
    ///   - key: The header to be set.
    ///   - value: The value for the header.
    func setHeader(key: String, value: String)

    /// Set the body of the request.
    ///
    /// - Parameters:
    ///   - The raw `Data` to be set for the request.
    func setData(_ data: Data)

    /// Initiate a raw request and pass the response to the given handler.
    ///
    /// - Parameters:
    ///   - The closure which gets the "associated" `Response` value.
    func requestRaw(_ handler: @escaping (Response) -> Void)
}

extension ClientCallable {
    /// Default method for setting the body using the given data. This sets
    /// the `Content-Length` header while setting the body.
    ///
    /// - Parameters:
    ///   - using: The `Data` for setting the body.
    public func setBody(using data: Data) {
        self.setHeader(key: "Content-Length", value: String(format: "%d", data.count))
        self.setData(data)
    }

    /// Encode the given `Mappable` object into the request body. This encodes the
    /// data, sets the body (using `setBody`) and sets `Content-Type` header as
    /// `application/json`
    ///
    /// - Parameters:
    ///   - using: The `Mappable` object to be encoded into the body.
    /// - Throws: `ServiceError` on failure to encode.
    public func setJSON<D: Mappable>(using data: D) throws {
        do {
            let encoder = JSONEncoder()
            let dateFormatter = DateFormatter()
            // NOTE: This should be same as the one in `ServiceClient`, `ServiceRequest` and `ServiceResponse` implementation.
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            encoder.dateEncodingStrategy = .formatted(dateFormatter)
            let jsonData = try encoder.encode(data)
            self.setBody(using: jsonData)
            self.setHeader(key: "Content-Type", value: "application/json")
        } catch {
            throw ServiceError.jsonSerialization
        }
    }
}
