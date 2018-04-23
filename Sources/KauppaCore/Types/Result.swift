/// Result type (inspired from Rust)
public enum Result<T, E: Error> {
    case ok(T)
    case err(E)

    /// Unwraps the value from the result or throws the error.
    ///
    /// Returns: Value from "Ok" variant (if it exists).
    /// Throws: Value from "Err" variant (it it doesn't).
    public func unwrapOrThrow() throws -> T {
        switch self {
            case .ok(let value):
                return value
            case .err(let error):
                throw error
        }
    }
}
