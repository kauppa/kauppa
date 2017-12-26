import Foundation

/// Mappable acts as a connector between the data store and the entity structure.
public protocol Mappable: Codable {
    //
}

extension UUID: Mappable {}
extension String: Mappable {}
