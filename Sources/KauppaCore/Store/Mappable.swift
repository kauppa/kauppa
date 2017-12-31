import Foundation

/// Mappable acts as a connector between the data store and the entity structure.
public protocol Mappable: Codable {
    //
}

extension UUID: Mappable {}
extension String: Mappable {}

/// While codable structs and class containing arrays can be encoded/decoded, the arrays
/// themselves cannot be encoded/decoded directly using the standard JSONEncoder/JSONDecoder.
/// This serves as a wrapper type for doing the same.
public struct MappableArray<T>: Mappable {
    public let inner: [T]

    /// Initialize an instance for an array of `Mappable` objects.
    public init(for array: [T]) {
        self.inner = array
    }

    public init(from decoder: Decoder) throws {
        let array = try Array<T>(from: decoder)
        self.init(for: array)
    }

    public func encode(to encoder: Encoder) throws {
        try self.inner.encode(to: encoder)
    }
}
