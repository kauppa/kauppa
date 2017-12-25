import Foundation

import KauppaCore

/// An attribute defined by the user.
public struct Attribute: Mappable {
    /// Unique ID of this attribute.
    public let id: UUID
    /// Lower-case name of this attribute.
    public var name: String
    /// Type of this attribute.
    public let type: BaseType
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public let updatedAt: Date

    public init(with name: String, and type: BaseType) {
        let date = Date()
        id = UUID()
        self.name = name
        self.type = type
        createdOn = date
        updatedAt = date
    }
}

/// A custom attribute declared/defined while creating/updating a product.
public typealias CustomAttribute = AttributeValue<String, String>

/// Attribute object used in product data.
public struct AttributeValue<V: Mappable, U: Mappable>: Mappable {
    /// Unique ID of this attribute (optional because this is set by the service once it's defined).
    public var id: UUID? = nil
    /// Name of this attribute - case insensitive (optional because it's required only during definition).
    public var name: String? = nil
    /// Type of this attribute (optional because it's required only during definition).
    public var type: BaseType? = nil
    /// Value for this attribute (mandatory).
    public var value: V
    /// Unit used by this attribute's value (optional).
    public var unit: U? = nil
}

extension AttributeValue where V == String, U == String {
    /// Validate the user-defined attribute for possible errors.
    public func validate() throws {
        guard name != nil else {
            throw ProductsError.invalidAttributeName
        }

        guard type != nil else {
            throw ProductsError.attributeRequiresType
        }
    }
}
