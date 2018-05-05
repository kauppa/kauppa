import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaProductsModel
import KauppaProductsRepository
import KauppaTaxClient

/// Factory class for creating/updating product. This validates the product data,
/// checks variants, custom attributes, sets tax and creates/updates product in the repository.
class ProductsFactory {
    var data: Product
    let address: Address?
    let repository: ProductsRepository

    /// Initialize this factory with the product data, repository and the address
    /// of the account.
    ///
    /// - Parameters:
    ///   - for: The `Product` object used by this factory.
    ///   - with: `ProductsRepository`
    ///   - from: (Optional) address from which this product was created.
    init(for data: Product, with repository: ProductsRepository, from address: Address? = nil) {
        self.data = data
        self.repository = repository
        self.address = address

        // Ensure that some properties can't be "set" manually
        self.data.variants = nil
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

        // Initialize the object.
        let productId = UUID()
        let date = Date()
        data.id = productId
        data.createdOn = date
        data.updatedAt = date

        var variant: Product? = nil

        // Check the variant data (if provided)
        if let variantId = data.variantId {
            do {
                variant = try repository.getProduct(for: variantId)
                // also check whether this is another variant (if so, use its parent)
                if let parentId = variant!.variantId {
                    variant = try repository.getProduct(for: parentId)
                    data.variantId = parentId
                }
            } catch {   // FIXME: check the error kind
                data.variantId = nil
            }
        }

        if var variantData = variant {
            if variantData.variants == nil {
                variantData.variants = [productId]
            } else {
                variantData.variants!.insert(productId)
            }

            let _ = try repository.updateProduct(with: variantData)
        }

        let _ = try repository.createProduct(with: data)
        return data
    }

    /// Method to update the product using the initialized data and the provided patch.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the product to be updated.
    ///   - with: The `ProductPatch` data used for updating the product.
    ///   - using: Anything that implements `TaxServiceCallable`
    /// - Throws: `ServiceError` on failure.
    func updateProduct(for id: UUID, with patch: ProductPatch, using taxService: TaxServiceCallable) throws {
        data.updatedAt = Date()

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

        if let price = patch.actualPrice {
            data.actualPrice = price
        }

        if let price = patch.price {
            data.price = price
        }

        if let currency = patch.currency {
            data.currency = currency
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
                if let parentId = variant.variantId {
                    variant = try repository.getProduct(for: parentId)
                }

                data.variantId = variant.id
                if variant.variants == nil {
                    variant.variants = [id]
                } else {
                    variant.variants!.insert(id)
                }

                let _ = try repository.updateProduct(with: variant)
            }
        }

        let _ = try repository.updateProduct(with: data)
    }

    /// Validate the categories in product data and create/update the store correspondingly.
    private func validateCategories() throws {
        guard let existingCategories = data.categories else {
            return
        }

        var categories = [Category]()

        for category in existingCategories {
            var category = category

            if let id = category.id {
                // Product data has category ID - Ensure that it exists in store.
                category = try repository.getCategory(for: id)
            } else if var name = category.name {
                // Category has been addressed with name.
                name = name.lowercased()
                if name.isEmpty {
                    continue
                }

                if let data = try? repository.getCategory(for: name) {
                    // Category name already exists. Re-use its ID.
                    category = data
                } else {
                    // Category doesn't exist - create it.
                    category = try repository.createCategory(with: category)
                }
            } else {
                // Invalid category data - ignore.
                continue
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
        guard var existingAttributes = data.custom else {
            return
        }

        for (index, customAttribute) in existingAttributes.enumerated() {
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
            existingAttributes[index].id = customAttribute.id
            existingAttributes[index].value = customAttribute.value
            existingAttributes[index].unit = customAttribute.unit
            existingAttributes[index].name = nil
            existingAttributes[index].type = nil
            existingAttributes[index].variants = nil
        }

        data.custom = existingAttributes
    }
}
