import Foundation

import KauppaCore
import KauppaTaxModel

/// Product information object.
public struct Product: Mappable {
    /// Unique identifier for this product.
    public var id: UUID? = UUID()
    /// Creation timestamp
    public var createdOn: Date?
    /// Last updated timestamp
    public var updatedAt: Date?
    /// Title for this product.
    public var title: String
    /// Subtitle for this product.
    public var subtitle: String
    /// A description of this product.
    public var description: String
    /// Overview of this product.
    public var overview: String? = nil
    /// Categories for this product.
    public var categories: [Category]? = []
    /// Tags for this product
    public var tags: ArraySet<String>? = ArraySet()
    /// Dimensions of this product (length, width and height - all are optional)
    public var dimensions: Dimensions? = nil
    /// Color in hex code
    public var color: String? = nil
    /// Weight of this product in some chosen measurement.
    public var weight: UnitMeasurement<Weight>? = nil
    /// Amount of items of this product in the inventory
    public var inventory: UInt32 = 0
    /// Base64-encoded images (or) Image URLs.
    public var images: ArraySet<String>? = ArraySet()
    /// Retail price of the product.
    public var price = Price()
    /// Currency used in this product.
    public var currency = Currency.usd
    /// Wholesale price of the product (currency is same as the one in retail price).
    public var actualPrice: Price? = nil
    /// Specify whether this price is inclusive of taxes.
    public var taxInclusive: Bool? = false
    /// Tax data for this product.
    public var tax: UnitTax? = nil
    /// Category of the product when it comes to calculating tax.
    public var taxCategory: String? = nil
    /// (child) variants of this product. For now, the variants belong to a single parent
    /// product, and hence this is an internal property. It shouldn't be updated
    /// manually by the user. Instead, the user should attach the ID of the parent
    /// product to the child through `variantId`
    public var variants: Set<UUID>? = []
    /// ID of the (parent) product to which this is a variant. Attaching this will
    /// automatically add this product to the parent's variants.
    public var variantId: UUID? = nil
    /// List of custom attributes defined/used in the product.
    public var custom: [CustomAttribute]? = []

    /// Initialize this object with title and description (for tests).
    init(title: String, subtitle: String, description: String) {
        let date = Date()
        self.createdOn = date
        self.updatedAt = date
        self.title = title
        self.subtitle = subtitle
        self.description = description
    }

    /// Set the tax-related properties using the given `TaxRate`
    ///
    /// NOTE: The `price` should be exclusive of tax.
    ///
    /// - Parameters:
    ///   - using: The `TaxRate` to be used for calculation.
    public mutating func setTax(using taxRate: TaxRate) {
        tax = UnitTax()     // initialize tax data
        var rate = taxRate.general
        if let category = self.taxCategory {
            if let r = taxRate.categories[category] {
                // If the category exists, set that category for tax.
                tax!.category = category
                rate = r
            }
        }

        tax!.rate = rate
        tax!.total = Price(rate * 0.01 * price.value)
        tax!.inclusive = taxInclusive ?? false
    }

    /// Perform basic validation on product data. Currently, this checks the
    /// title, subtitle, description and color (for valid hex value).
    ///
    /// - Throws: `ServiceError` for invalid data.
    public func validate() throws {
        if title.isEmpty {
            throw ServiceError.invalidProductTitle
        }

        if subtitle.isEmpty {
            throw ServiceError.invalidProductSubtitle
        }

        if description.isEmpty {
            throw ServiceError.invalidProductDescription
        }

        if let color = color {
            /// Checks whether color is a valid CSS-compliant hex color.
            if !color.isMatching(regex: "^#(?:[0-9a-fA-F]{3}){1,2}$") {
                throw ServiceError.invalidProductColor
            }
        }
    }
}
