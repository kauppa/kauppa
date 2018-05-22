
/// Marker type for `Optional` - adds a few methods to the optional types.
public protocol OptionalType {
    /// Checks whether this type has some value.
    ///
    /// - Returns: `true` if the value is not `nil`.
    func isSome() -> Bool

    /// Checks whether this type is `nil`.
    ///
    /// - Returns: `true` if the value is `nil`.
    func isNone() -> Bool
}

extension Optional: OptionalType {
    public func isSome() -> Bool {
        switch self {
            case .none: return false
            case .some: return true
        }
    }

    public func isNone() -> Bool {
        switch self {
            case .none: return true
            case .some: return false
        }
    }
}
