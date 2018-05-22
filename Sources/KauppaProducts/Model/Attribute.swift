import Foundation

import KauppaCore

/// An attribute defined by the user.
public struct Attribute: Mappable {
    /// Unique ID of this attribute.
    public var id: UUID
    /// Lower-case name of this attribute.
    public var name: String
    /// Type of this attribute.
    public let type: BaseType
    /// If this were an enum, then the variants of the enum.
    public var variants: ArraySet<String>? = nil
    /// Creation timestamp
    public var createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date

    /// Initialize an instance with all the properties.
    public init(id: UUID, name: String, type: BaseType, createdOn: Date, updatedAt: Date) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = updatedAt
        self.name = name
        self.type = type
    }

    /// Initialize an instance with name and type.
    ///
    /// - Parameters:
    ///   - with: The name of this attribute.
    ///   - and: The `BaseType` of this attribute.
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
    /// If this were an enum, then the variants of the enum.
    public var variants: ArraySet<String>? = nil
    /// Value for this attribute (mandatory).
    public var value: V
    /// Unit used by this attribute's value (optional).
    public var unit: U? = nil

    /// Initialize an instance with a value. All other fields are set to `nil`
    ///
    /// - Parameters:
    ///   - with: The `value` of this attribute.
    public init(with value: V) {
        self.value = value
    }
}

extension AttributeValue where V == String, U == String {
    /// Validate the user-defined attribute for possible errors.
    ///
    /// - Throws: `ServiceError` on failure in validation.
    public mutating func validate() throws {
        guard let name = name else {
            throw ServiceError.invalidAttributeName
        }

        guard let type = type else {
            throw ServiceError.attributeRequiresType
        }

        if (name.isEmpty) {
            throw ServiceError.invalidAttributeName
        }

        self.name = name.lowercased()

        if type == .enum_ {
            try validateEnum()
        } else if (value.isEmpty) {
            throw ServiceError.invalidAttributeValue
        }

        guard let _ = type.parse(value: value) else {
            throw ServiceError.invalidAttributeValue
        }

        if type.hasUnit {
            guard let unit = unit else {
                throw ServiceError.attributeRequiresUnit
            }

            guard let _ = type.parse(unit: unit) else {
                throw ServiceError.invalidAttributeUnit
            }
        }
    }

    /// Validate enum variants for possible errors.
    private mutating func validateEnum() throws {
        guard let declaredVariants = self.variants else {
            throw ServiceError.notEnoughVariants
        }

        var newVariants = ArraySet<String>()
        for variant in declaredVariants {
            if variant.isEmpty {
                throw ServiceError.invalidEnumVariant
            }

            newVariants.insert(variant.lowercased())
        }

        if newVariants.count < 2 {
            throw ServiceError.notEnoughVariants
        }

        self.value = value.lowercased()
        self.variants = newVariants

        if !newVariants.contains(self.value) {
            throw ServiceError.invalidAttributeValue
        }
    }
}
