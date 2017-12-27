import Foundation

public protocol ClientCallable {

    associatedtype Response: ClientResponse

    associatedtype ClientError: ServiceError

    init(with method: HTTPMethod, on url: String)

    func setBody(using data: Data)

    func requestRaw(_ handler: @escaping (Response) throws -> Void)
}

extension ClientCallable {
    public init<R: RouteRepresentable>(using repr: R, with parameters: [String: String]) {
        let route = repr.route
        // TODO: Expand route with parameters

        self.init(with: route.method, on: route.url)
    }
}
