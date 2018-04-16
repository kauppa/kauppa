import Foundation

import KauppaCore

public struct Product: Mappable {
    /// Unique identifier for this product.
    public let id = UUID()
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// Product's data supplied by the user.
    public var data: ProductData

    /// Initialize with the given product data.
    ///
    /// - Parameters:
    ///   - with: The `ProductData` object.
    public init(with data: ProductData) {
        let date = Date()
        self.createdOn = date
        self.updatedAt = date
        self.data = data
    }

    /// Initialize an empty version of this type (for tests).
    init() {
        self.init(with: ProductData(title: "", subtitle: "", description: ""))
    }
}
