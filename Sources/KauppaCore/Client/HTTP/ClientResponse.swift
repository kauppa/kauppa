import Foundation

/// Protocol for the response returned by a `ClientCallable` implementor.
public protocol ClientResponse {
    /// Status code of the response.
    var statusCode: HTTPStatusCode { get }

    /// Returns the raw data from the response.
    ///
    /// - Returns: `Data` (if it's possible).
    func getData() -> Data?
}
