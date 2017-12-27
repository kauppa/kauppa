import Dispatch
import Foundation

open class ServiceClient<C: ClientCallable, E: ServiceError>: ClientCallable {
    public typealias Response = C.Response

    private let client: C

    required public init(with method: HTTPMethod, on url: URL) {
        self.client = C(with: method, on: url)
    }

    public func setBody(using data: Data) {
        self.client.setBody(using: data)
    }

    public func requestRaw(_ handler: @escaping (Response) -> Void) {
        self.client.requestRaw(handler)
    }

    public func request<D: Mappable>() throws -> D {
        var result: Result<D, E>? = nil
        var otherError: GenericError = GenericError.unknownError

        let task: (Response) throws -> Void = { response in
            guard let data = response.getData() else {
                throw GenericError.clientHTTPData
            }

            let code = response.statusCode
            if code.rawValue < 400 {
                do {
                    let decoded = try JSONDecoder().decode(D.self, from: data)
                    result = .ok(decoded)
                    return
                } catch {
                    throw GenericError.jsonParse
                }
            }

            do {
                let error = try JSONDecoder().decode(MappableServiceError.self, from: data)
                guard let serviceError = E(rawValue: error.code) else {
                    throw GenericError.jsonErrorParse
                }

                throw serviceError
            } catch {
                throw GenericError.jsonErrorParse
            }
        }

        let group = DispatchGroup()
        group.enter()

        DispatchQueue.main.async {
            self.requestRaw() { response in
                do {
                    try task(response)
                } catch let err as E {
                    result = .err(err)
                } catch let err as GenericError {
                    otherError = err
                } catch {
                    //
                }

                group.leave()
            }
        }

        group.wait()

        if let result = result {
            return try result.unwrapOrThrow()
        }

        throw otherError
    }
}
