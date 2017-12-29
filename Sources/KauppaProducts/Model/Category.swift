import Foundation

import KauppaCore

/// A product/collection category.
public struct Category: Mappable {
    /// Unique ID of this category.
    public var id: UUID? = nil
    /// Name of this category.
    public var name: String? = nil
    /// Description for this category.
    public var description: String? = nil

    /// Initialize this category with a name and description.
    public init(name: String, description: String? = nil) {
        self.name = name
        self.description = description
    }
}
