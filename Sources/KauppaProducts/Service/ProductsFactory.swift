import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaProductsModel
import KauppaProductsRepository
import KauppaTaxClient

class ProductsFactory {
    var data: ProductData
    let address: Address
    let repository: ProductsRepository

    init(for data: ProductData, with repository: ProductsRepository, from address: Address) {
        self.data = data
        self.repository = repository
        self.data.variants = []     // ensure that variants can't be "set" manually
        self.address = address
    }

    /// Validate the product's custom attributes (create/update the store data correspondingly).
    private func validateCustomAttributes() throws {
        for (index, customAttribute) in data.custom.enumerated() {
            var customAttribute = customAttribute

            if let id = customAttribute.id {
                let attribute = try repository.getAttribute(for: id)
                customAttribute.name = attribute.name
                customAttribute.type = attribute.type
                if attribute.type == .enum_ {
                    customAttribute.variants = attribute.variants
                }
            } else {
                try customAttribute.validate()
                let attribute = try repository.createAttribute(with: customAttribute.name!,
                                                               and: customAttribute.type!)
                customAttribute.id = attribute.id
                customAttribute.name = attribute.name
            }

            guard let _ = customAttribute.type!.parse(value: customAttribute.value) else {
                throw ProductsError.invalidAttributeValue
            }

            if customAttribute.type! == .enum_ {
                if !customAttribute.variants!.contains(customAttribute.value) {
                    throw ProductsError.invalidAttributeValue
                }
            }

            if customAttribute.type!.hasUnit {
                guard let unit = customAttribute.unit else {
                    throw ProductsError.attributeRequiresUnit
                }

                guard let _ = customAttribute.type!.parse(unit: unit) else {
                    throw ProductsError.invalidAttributeUnit
                }
            }

            // Reset the name and type.
            data.custom[index].id = customAttribute.id
            data.custom[index].name = nil
            data.custom[index].type = nil
        }
    }

    /// Method to create product using the initialized data.
    func createProduct(using taxService: TaxServiceCallable) throws -> Product {
        try data.validate()
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

        let taxRate = try taxService.getTaxRate(for: address)
        data.stripTax(using: taxRate)

        let product = Product(data: data)
        let _ = try repository.createProduct(with: product)
        if let variant = variant {
            var variantData = variant.data
            variantData.variants.insert(product.id)
            let _ = try repository.updateProduct(for: variant.id, with: variantData)
        }

        return product
    }

    /// Method to update the product using the initialized data and the provided patch.
    func updateProduct(for id: UUID, using patch: ProductPatch, taxService: TaxServiceCallable) throws {
        if let title = patch.title {
            data.title = title
        }

        if let subtitle = patch.subtitle {
            data.subtitle = subtitle
        }

        if let description = patch.description {
            data.description = description
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

        if let category = patch.category {
            data.category = category
        }

        if patch.taxInclusive ?? false {
            data.taxInclusive = true
            let taxRate = try taxService.getTaxRate(for: address)
            data.stripTax(using: taxRate)
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
                    let _ = try repository.updateProduct(for: variant.id, with: variantData)
                }
            }
        }

        let _ = try repository.updateProduct(for: id, with: data)
    }
}
