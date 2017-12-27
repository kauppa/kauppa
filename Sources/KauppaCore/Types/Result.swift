/// Result type (inspired from Rust)
public enum Result<T, E: Error> {
    case ok(T)
    case err(E)

    ///
    public func unwrapOrThrow() throws -> T {
        switch self {
            case .ok(let value):
                return value
            case .err(let error):
                throw error
        }
    }
}
