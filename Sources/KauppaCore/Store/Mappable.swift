import Foundation

/// Mappable acts as a connector between the data store and the entity structure.
public protocol Mappable: Codable {
    //
}

extension UUID: Mappable {}
extension String: Mappable {}

public struct MappableArray<T>: Mappable {
    private let inner: [T]

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
