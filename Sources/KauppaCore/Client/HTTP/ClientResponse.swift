import Foundation

public protocol ClientResponse {
    ///
    var statusCode: HTTPStatusCode { get }

    func getData() -> Data?
}
