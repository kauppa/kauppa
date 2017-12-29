import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaProductsModel
import KauppaProductsRepository
import KauppaTaxClient

/// Factory class for creating/updating product. This validates the product data,
/// checks variants, custom attributes, sets tax and creates/updates product in the repository.
class ProductsFactory {
    var data: ProductData
    let address: Address?
    let repository: ProductsRepository

    /// Initialize this factory with the product data, repository and the address
    /// of the account.
    ///
    /// - Parameters:
    ///   - for: The `ProductData` used by this factory.
    ///   - with: `ProductsRepository`
    ///   - from: (Optional) address from which this product was created.
    init(for data: ProductData, with repository: ProductsRepository, from address: Address? = nil) {
        self.data = data
        self.repository = repository
        self.address = address

        // ensure that some properties can't be "set" manually
        self.data.variants = []
        self.data.tax = nil
    }

    /// Method to create product using the initialized data (entrypoint to factory).
    ///
    /// - Parameters:
    ///   - using: Anything that implements `TaxServiceCallable`
    /// - Returns: `Product` (if it was successfully created).
    /// - Throws: `ServiceError` on failure.
    func createProduct(using taxService: TaxServiceCallable) throws -> Product {
        try data.validate()
        try validateCategories()
        try validateCustomAttributes()

        var variant: Product? = nil

        // Check the variant data (if provided)
        if let variantId = data.variantId {
            do {
                variant = try repository.getProduct(for: variantId)
                // also check whether this is another variant (if so, use its parent)
                if let parentId = variant!.data.variantId {
                    variant = try repository.getProduct(for: parentId)
                    data.variantId = variant!.id
                }
            } catch {   // FIXME: check the error kind
                data.variantId = nil
            }
        }

        let product = Product(with: data)
        let _ = try repository.createProduct(with: product)
        if let variant = variant {
            var variantData = variant.data
            variantData.variants.insert(product.id)
            let _ = try repository.updateProduct(for: variant.id, with: variantData)
        }

        return product
    }

    /// Method to update the product using the initialized data and the provided patch.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product to be updated.
    ///   - with: The `ProductPatch` data used for updating the product.
    ///   - using: Anything that implements `TaxServiceCallable`
    /// - Throws: `ServiceError` on failure.
    func updateProduct(for id: UUID, with patch: ProductPatch, using taxService: TaxServiceCallable) throws {
        if let title = patch.title {
            data.title = title
        }

        if let subtitle = patch.subtitle {
            data.subtitle = subtitle
        }

        if let description = patch.description {
            data.description = description
        }

        if let overview = patch.overview {
            data.overview = overview
        }

        if let categories = patch.categories {
            data.categories = categories
            try validateCategories()
        }

        if let tags = patch.tags {
            data.tags = tags
        }

        if let dimensions = patch.dimensions {
            if data.dimensions == nil {
                data.dimensions = dimensions
            } else {
                if let length = dimensions.length {
                    data.dimensions!.length = length
                }
                if let width = dimensions.width {
                    data.dimensions!.width = width
                }
                if let height = dimensions.height {
                    data.dimensions!.height = height
                }
            }
        }

        if let custom = patch.custom {
            data.custom = custom
            try validateCustomAttributes()
        }

        if let color = patch.color {
            data.color = color
        }

        if let weight = patch.weight {
            data.weight = weight
        }

        if let inventory = patch.inventory {
            data.inventory = inventory
        }

        if let images = patch.images {
            data.images = images
        }

        if let price = patch.price {
            data.price = price
        }

        if let category = patch.taxCategory {
            data.taxCategory = category
        }

        if patch.taxInclusive ?? false {
            data.taxInclusive = true
        }

        /// NOTE: `variants` cannot be updated directly.

        if let variantId = patch.variantId {
            if variantId != id {
                var variant = try repository.getProduct(for: variantId)
                // Check if it's a child - if so, use its variantId instead.
                if let parentId = variant.data.variantId {
                    variant = try repository.getProduct(for: parentId)
                }

                data.variantId = variant.id
                var variantData = variant.data
                if !variantData.variants.contains(id) {
                    variantData.variants.insert(id)
                    let _ = try? repository.updateProduct(for: variant.id, with: variantData)
                }
            }
        }

        let _ = try repository.updateProduct(for: id, with: data)
    }

    private func validateCategories() throws {
        var categories = [Category]()

        for category in data.categories {
            var category = category

            if let id = category.id {
                // Product data has category ID - Ensure that it exists in store.
                category = try repository.getCategory(for: id)
            } else if var name = category.name {
                // Category has been addressed with name.
                name = name.lowercased()
                if let data = try? repository.getCategory(for: name) {
                    // Category name already exists. Re-use its ID.
                    category = data
                } else {
                    // Category doesn't exist - create it.
                    category = try repository.createCategory(with: category)
                }
            } else {
                // Invalid category data - ignore.
            }

            // Append only if category doesn't already exist in product data.
            if categories.first(where: { $0.id != nil && $0.id! == category.id }) == nil {
                categories.append(category)
            }
        }

        data.categories = categories
    }

    /// Validate the product's custom attributes (create/update the store data correspondingly).
    private func validateCustomAttributes() throws {
        for (index, customAttribute) in data.custom.enumerated() {
            var customAttribute = customAttribute

            if let id = customAttribute.id {
                let attribute = try repository.getAttribute(for: id)
                // Set the necessary stuff required for validation.
                customAttribute.name = attribute.name
                customAttribute.type = attribute.type
                if attribute.type == .enum_ {
                    customAttribute.variants = attribute.variants
                }

                try customAttribute.validate()
            } else {
                try customAttribute.validate()
                let attribute = try repository.createAttribute(with: customAttribute.name!,
                                                               and: customAttribute.type!,
                                                               variants: customAttribute.variants)
                customAttribute.id = attribute.id
                customAttribute.name = attribute.name
            }

            // Set ID, value, unit and reset name, type and variants.
            data.custom[index].id = customAttribute.id
            data.custom[index].value = customAttribute.value
            data.custom[index].unit = customAttribute.unit
            data.custom[index].name = nil
            data.custom[index].type = nil
            data.custom[index].variants = nil
        }
    }
}
