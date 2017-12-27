import Dispatch
import Foundation

open class ServiceClient<C: ClientCallable, R: RouteRepresentable> {
    private let endpoint: URL

    public init?(for endpoint: String) {
        if let url = URL(string: endpoint, relativeTo: nil) {
            self.endpoint = url
        } else {
            return nil
        }
    }

    public func createClient(for repr: R, with parameters: [String: String]? = nil) throws -> C {
        let route = repr.route
        // TODO: Fill the generic URL with the given parameters.
        let endpoint = URL(string: route.url, relativeTo: self.endpoint)!
        return C(with: route.method, on: endpoint)
    }

    public func requestJSON<D: Mappable>(with client: C) throws -> D {
        var result: Result<D, ServiceError> = .err(.unknownError)

        let task: (C.Response) throws -> Void = { response in
            guard let data = response.getData() else {
                throw ServiceError.clientHTTPData
            }

            let code = response.statusCode
            if code.rawValue < 400 {
                do {
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    // NOTE: This should be same as `ServiceResponse` implementation.
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+zzzz"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    let decoded = try decoder.decode(D.self, from: data)
                    result = .ok(decoded)
                } catch {
                    //
                }

                return
            }

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

        return try result.unwrapOrThrow()
    }
}
