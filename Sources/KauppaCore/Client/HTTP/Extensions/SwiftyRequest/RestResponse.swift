import Foundation
import SwiftyRequest

/// Wrapper for the `RestResponse` - we had to go for a class because (at the time of
/// this writing), Swift didn't allow us to extend constrained types with a protocol.
public class SwiftyRestResponse: ClientResponse {
    private let inner: RestResponse<Data>

    init(with response: RestResponse<Data>) {
        inner = response
    }

    public var statusCode: HTTPStatusCode {
        /// This is infallible, because this is checked only after response data.
        let code = inner.response!.statusCode
        return HTTPStatusCode(rawValue: UInt16(code)) ?? .unknown
    }

    public func getData() -> Data? {
        return inner.data
    }
}
