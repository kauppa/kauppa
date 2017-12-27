import Foundation

public protocol ClientCallable {

    associatedtype Response: ClientResponse

    init(with method: HTTPMethod, on url: URL)

    func setBody(using data: Data)

    func requestRaw(_ handler: @escaping (Response) -> Void)
}
