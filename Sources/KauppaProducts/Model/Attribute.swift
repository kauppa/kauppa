import Foundation

import KauppaCore

/// An attribute defined by the user.
public struct Attribute: Mappable {
    /// Unique ID of this attribute.
    public var id: UUID
    /// Name of this attribute (case insensitive)
    public var name: String
    /// Type of this attribute.
    public var type: BaseType
}

/// Attribute object used in product data.
public struct AttributeValue<Value: Mappable, Unit: Mappable>: Mappable {
    /// Unique ID of this attribute (optional because this is set by the service once it's defined).
    public var id: UUID? = nil
    /// Name of this attribute - case insensitive (optional because it's required only during definition).
    public var name: String? = nil
    /// Type of this attribute (optional because it's required only during definition).
    public var type: BaseType? = nil
    /// Value for this attribute (mandatory).
    public var value: Value
    /// Unit used by this attribute's value (optional).
    public var unit: Unit
}
