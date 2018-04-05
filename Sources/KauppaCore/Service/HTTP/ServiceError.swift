/// Represents an error in service call, which is encoded into the response.
public struct ServiceError: Encodable {
    /// The message for this error.
    let message: String

    public init(message: String) {
        self.message = message
    }
}
