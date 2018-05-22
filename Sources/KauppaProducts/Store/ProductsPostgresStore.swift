import Foundation

import KauppaCore
import KauppaProductsModel
import SwiftKuery

/// Products store backed by PostgreSQL database.
public class ProductsPostgresStore<D: Database>: ProductsStorable {

    private let database: D

    public init(with database: D) {
        self.database = database
    }

    public func createNewProduct(with data: Product) throws -> () {
        // Overwrite attribute values.
        try updateAttributeValues(for: data.id!, using: data.custom ?? [])

        // Collect product data and insert them.
        let products = Products.table
        let dataValues: [Any?] = [data.id, data.createdOn, data.updatedAt,
                                  data.title, data.subtitle, data.description, data.overview,
                                  data.images, data.categories, data.tags,
                                  data.dimensions?.length?.value, data.dimensions?.length?.unit,
                                  data.dimensions?.width?.value, data.dimensions?.width?.unit,
                                  data.dimensions?.height?.value, data.dimensions?.height?.unit,
                                  data.weight?.value, data.weight?.unit,
                                  data.color, data.inventory, data.price, data.actualPrice,
                                  data.currency, data.taxInclusive, data.variants, data.variantId]

        let (columns, values, params) = products.createParameters(for: products.allColumns, with: dataValues)
        let insert = Insert(into: products, columns: columns, values: params)
        try database.execute(query: insert, with: values as! [D.ValueConvertible])
    }

    public func getProduct(for id: UUID) throws -> Product {
        throw ServiceError.invalidProductId
    }

    public func deleteProduct(for id: UUID) throws -> () {}

    public func updateProduct(with data: Product) throws -> () {}

    public func createNewCollection(with data: ProductCollection) throws -> () {}

    public func getCollection(for id: UUID) throws -> ProductCollection {
        throw ServiceError.invalidCollectionId
    }

    public func updateCollection(with data: ProductCollection) throws -> () {}

    public func deleteCollection(for id: UUID) throws -> () {}

    public func createAttribute(with data: Attribute) throws -> () {
        let attributes = Attributes.table
        let dataValues: [Any?] = [data.id, data.name, data.type, data.variants, data.createdOn, data.updatedAt]
        let (columns, values, params) = attributes.createParameters(for: attributes.allColumns, with: dataValues)
        let insert = Insert(into: attributes, columns: columns, values: params)
        try database.execute(query: insert, with: values as! [D.ValueConvertible])
    }

    public func getAttribute(for id: UUID) throws -> Attribute {
        throw ServiceError.invalidAttributeId
    }

    public func createCategory(with data: Category) throws -> () {}

    public func getCategory(for id: UUID) throws -> Category {
        throw ServiceError.invalidCategoryId
    }

    public func getCategory(for name: String) throws -> Category {
        throw ServiceError.invalidCategoryName
    }

    public func getCategories() throws -> [Category] {
        return []
    }

    private func updateAttributeValues(for entityId: UUID, using attributes: [CustomAttribute]) throws {
        let attributeValues = AttributeValues.table

        // Delete existing values for overwriting them.
        let delete = Delete(from: attributeValues).where(attributeValues.entityId == Parameter())
        try database.execute(query: delete, with: [entityId] as! [D.ValueConvertible])

        if attributes.isEmpty {     // If there aren't any values, then we're done.
            return
        }

        // Collect the attribute values.
        var attributeData = [Any?]()
        for attribute in attributes {
            var row: [Any] = [attribute.id!, entityId, "", false, 0, 0.0, ""]   // set defaults
            switch attribute.type! {
                case .string, .enum_:
                    row[2] = attribute.value
                case .boolean:
                    row[3] = Bool(attribute.value)!
                case .number:
                    row[4] = UInt32(attribute.value)!
                default:
                    row[5] = Float32(attribute.value)!
            }

            row[6] = attribute.unit ?? ""
            attributeData.append(contentsOf: row)
        }

        let attributeParams: [[Any]] = attributes.map { _ in
            Array(repeating: Parameter(), count: attributeValues.allColumns.count)
        }

        let insert = Insert(into: attributeValues, rows: attributeParams)
        try database.execute(query: insert, with: attributeParams as! [D.ValueConvertible])
    }
}
