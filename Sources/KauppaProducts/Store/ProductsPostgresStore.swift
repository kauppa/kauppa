import Foundation

import KauppaCore
import KauppaProductsModel
import SwiftKuery

/// Products store backed by PostgreSQL database.
public class ProductsPostgresStore<D: Database>: ProductsStorable {

    private let database: D

    /// Initialize this store with a database. This also executes the queries
    /// for creating the tables.
    ///
    /// - Parameter:
    ///   - with: Anything that implements `Database`
    public init(with database: D) throws {
        self.database = database

        try database.execute(query: BuildableTable(for: Categories.table), with: [])
        try database.execute(query: BuildableTable(for: Products.table), with: [])
        try database.execute(query: BuildableTable(for: Attributes.table), with: [])
        try database.execute(query: BuildableTable(for: AttributeValues.table), with: [])
    }

    public func createNewProduct(with data: Product) throws -> () {
        // Overwrite attribute values.
        try updateAttributeValues(for: data.id!, using: data.custom ?? [])

        // Collect product data and insert them.
        let products = Products.table
        let dataValues: [Any?] = [data.id, data.createdOn, data.updatedAt,
                                  data.title, data.subtitle, data.description, data.overview,
                                  Array(data.images), data.categories?.map { $0.id! }, Array(data.tags),
                                  data.dimensions?.length?.value, data.dimensions?.length?.unit.rawValue,
                                  data.dimensions?.width?.value, data.dimensions?.width?.unit.rawValue,
                                  data.dimensions?.height?.value, data.dimensions?.height?.unit.rawValue,
                                  data.weight?.value, data.weight?.unit.rawValue,
                                  data.color, data.inventory, data.price.value, data.actualPrice?.value,
                                  data.currency.rawValue, data.taxInclusive, data.taxCategory,
                                  Array(data.variants), data.variantId, true]

        let (columns, values, params) = products.createParameters(with: dataValues)
        let insert = Insert(into: products, columns: columns, values: params)
        try database.execute(query: insert, with: values)
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
        let dataValues: [Any?] = [data.id, data.createdOn, data.updatedAt, data.name, data.type.rawValue, data.variants]
        let (columns, values, params) = attributes.createParameters(with: dataValues)
        let insert = Insert(into: attributes, columns: columns, values: params)
        try database.execute(query: insert, with: values)
    }

    public func getAttribute(for id: UUID) throws -> Attribute {
        let attributes = Attributes.table
        let select = Select(from: attributes).where(attributes.id == Parameter())
        let rows = try database.execute(query: select, with: [id])
        if rows.isEmpty {
            throw ServiceError.invalidAttributeId
        }

        let type: String = try rows[0].getValue(forField: attributes.type)
        let variants: [String]? = try? rows[0].getValue(forField: attributes.variants)
        var attribute = Attribute(id: try rows[0].getValue(forField: attributes.id),
                                  name: try rows[0].getValue(forField: attributes.name),
                                  type: BaseType(rawValue: type)!,
                                  createdOn: try rows[0].getValue(forField: attributes.createdOn),
                                  updatedAt: try rows[0].getValue(forField: attributes.updatedAt))
        attribute.variants = ArraySet(variants ?? [])

        return attribute
    }

    public func createCategory(with data: Category) throws -> () {
        let categories = Categories.table
        let dataValues: [Any?] = [data.id, data.name, data.description]
        let (columns, values, params) = categories.createParameters(with: dataValues)
        let insert = Insert(into: categories, columns: columns, values: params)
        try database.execute(query: insert, with: values)
    }

    public func getCategory(for id: UUID) throws -> Category {
        let categories = Categories.table
        let select = Select(from: categories).where(categories.id == Parameter())
        let rows = try database.execute(query: select, with: [id])
        if rows.isEmpty {
            throw ServiceError.invalidCategoryId
        }

        let name: String = try rows[0].getValue(forField: categories.name)
        let description: String? = try? rows[0].getValue(forField: categories.description)
        var category = Category(name: name, description: description)
        category.id = try rows[0].getValue(forField: categories.id)

        return category
    }

    public func getCategory(for name: String) throws -> Category {
        let categories = Categories.table
        let select = Select(from: categories).where(categories.name == Parameter())
        let rows = try database.execute(query: select, with: [name])
        if rows.isEmpty {
            throw ServiceError.invalidCategoryName
        }

        let name: String = try rows[0].getValue(forField: categories.name)
        let description: String? = try? rows[0].getValue(forField: categories.description)
        var category = Category(name: name, description: description)
        category.id = try rows[0].getValue(forField: categories.id)

        return category
    }

    public func getCategories() throws -> [Category] {
        return []
    }

    private func updateAttributeValues(for entityId: UUID, using attributes: [CustomAttribute]) throws {
        let attributeValues = AttributeValues.table

        // Delete existing values for overwriting them.
        let delete = Delete(from: attributeValues).where(attributeValues.entityId == Parameter())
        try database.execute(query: delete, with: [entityId])

        if attributes.isEmpty {     // If there aren't any values, then we're done.
            return
        }

        // Collect the attribute values.
        var attributeData = [Any]()
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
        try database.execute(query: insert, with: attributeData)
    }
}
