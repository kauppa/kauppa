import Dispatch
import Foundation

/// Wrapper for the clients of each service. Since all the services use JSON to talk
/// to one another, since they have some common rules of how the data is exchanged
/// and since we don't wanna duplicate code here and there, this wrapper exists.
///
/// It provides a few basic methods to ease the implementation of service
/// calls for a service client.
open class ServiceClient<C: ClientCallable, R: RouteRepresentable> {

    private let endpoint: URL

    /// Initialize this client with a root URL. All service calls make
    /// use of routes relative to this URL.
    ///
    /// - Parameters:
    ///   - for: The URL as a string.
    public init?(for endpoint: String) {
        if let url = URL(string: endpoint, relativeTo: nil) {
            self.endpoint = url
        } else {
            return nil
        }
    }

    /// Create the client for the given route with the parameters to be filled in the route.
    /// It returns the client so that the service implementation can modify it if it wants to
    /// (say, for setting headers).
    ///
    /// - Parameters:
    ///   - for: A route (essentially, a `RouteRepresentable` object).
    ///   - with: The values for parameters in the route.
    /// - Returns: The `ClientCallable` object initialized with the URL and HTTP method.
    /// - Throws: `ServiceError` if the parameter values are invalid.
    public func createClient(for repr: R, with parameters: [String: String]? = nil) throws -> C {
        let route = repr.route
        // TODO: Fill the generic URL with the given parameters.
        let endpoint = URL(string: route.url, relativeTo: self.endpoint)!
        return C(with: route.method, on: endpoint)
    }

    /// Initiate a request with the HTTP client (created using `createClient`).
    /// This assumes that the response is expected to contain JSON data that can be
    /// decoded into a `Mappable` object.
    ///
    /// - Parameters:
    ///   - with: The `ClientCallable` object created by this class.
    /// - Returns: The `Mappable` from the response (if the decode was successful).
    /// - Throws:
    ///   - `ServiceError` if there's no response data, if it was unexpected (i.e., not decodable
    ///   and not a `ServiceError`), or if the returned error code was invalid.
    ///
    /// Since almost all HTTP clients are async, this method also pauses the execution
    /// until the response is obtained. This shouldn't affect the performance, because
    /// we use the dispatch queue to notify us after getting the response, and the
    /// service execution is continued.
    ///
    /// If the service returns anything other than 2xx status codes, then this assumes
    /// that an error has been returned by the service, and it tries to decode the response
    /// data into `ServiceStatusMessage` (which is supposed to contain the error code).
    /// If that's been successfully decoded, then this throws that error.
    public func requestJSON<D: Mappable>(with client: C) throws -> D {
        // Initialize the result with "unknown error" (fallback when everything fails).
        var result: Result<D, ServiceError> = .err(.unknownError)

        let task: (C.Response) throws -> Void = { response in
            // Response data is required.
            guard let data = response.getData() else {
                throw ServiceError.clientHTTPData
            }

            let code = response.statusCode
            if code.rawValue >= 200 && code.rawValue < 300 {    // check for 2xx code
                do {
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    // NOTE: This format should be same as the one in `ServiceResponse` implementation.
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    let decoded = try decoder.decode(D.self, from: data)
                    result = .ok(decoded)
                } catch {
                    // Error decoding the object. This will default to "unknown error".
                }

                return
            }

            // Non-2xx code - try to decode the status message for getting error code.

            do {
                let serviceResponse = try JSONDecoder().decode(ServiceStatusMessage.self, from: data)
                guard let code = serviceResponse.code else {
                    // Service has issued an error, but no code was received.
                    return
                }

                guard let serviceError = ServiceError(rawValue: code) else {
                    // Service has returned a code, but we've no idea what that is.
                    return
                }

                throw serviceError
            } catch {
                throw ServiceError.jsonErrorParse
            }
        }

        // The whole task is carried out in async. Pause the execution using
        // a dispatch group.

        let group = DispatchGroup()
        group.enter()

        DispatchQueue.main.async {
            client.requestRaw() { response in
                do {
                    try task(response)
                } catch {
                    //
                }

                group.leave()
            }
        }

        group.wait()

        // At this point, it's either a successfully decoded data or a throwable error.
        return try result.unwrapOrThrow()
    }
}
