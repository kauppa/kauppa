/// Marker protocol for all types that represent an unit.
public protocol Unit {
    /// The string representation of this unit.
    var rawValue: String { get }
    /// Initialize this type from a string. It's `nil` if the string is invalid.
    init?(rawValue: String)
}
