import Foundation

import SwiftKuery

import KauppaCore
import KauppaProductsModel

/// Table for `Product` model.
class ProductTable: DatabaseModel<Product> {

    let tableName = "products"

    static let table = ProductTable()

    let id              = Column("id", UUID.self, primaryKey: true, notNull: true, unique: true)
    let createdOn       = Column("created_on", Timestamp.self, notNull: true)
    let updatedAt       = Column("updated_at", Timestamp.self, notNull: true)

    let title           = Column("title", String.self, notNull: true)
    let subtitle        = Column("subtitle", String.self)
    let description     = Column("description", String.self)
    let overview        = Column("overview", String.self)
    let images          = Column("images", SQLArray<String>.self)

    let categories      = Column("categories", SQLArray<UUID>.self)
    let tags            = Column("tags", SQLArray<String>.self)

    let lengthValue     = Column("length_value", Float.self)
    let lengthUnit      = Column("length_unit", String.self)
    let widthValue      = Column("width_value", Float.self)
    let widthUnit       = Column("width_unit", String.self)
    let heightValue     = Column("height_value", Float.self)
    let heightUnit      = Column("height_unit", String.self)
    let weightValue     = Column("weight_value", Float.self)
    let weightUnit      = Column("weight_unit", String.self)
    let color           = Column("color", String.self)

    let inventory       = Column("inventory", Int16.self, notNull: true)
    let price           = Column("price", Float.self, notNull: true)
    let actualPrice     = Column("actual_price", Float.self)
    let currency        = Column("currency", String.self, notNull: true)
    let taxInclusive    = Column("tax_inclusive", Bool.self)
    let taxCategory     = Column("tax_category", String.self)

    let variants        = Column("variants", SQLArray<UUID>.self)
    let variantId       = Column("variantId", UUID.self)

    let active          = Column("active", Bool.self)

    public override func values(from model: Product) -> [Any?] {
        return [
            model.id, model.createdOn, model.updatedAt,
            model.title, model.subtitle, model.description, model.overview,
            Array(model.images), model.categories?.map { $0.id! }, Array(model.tags),
            model.dimensions?.length?.value, model.dimensions?.length?.unit.rawValue,
            model.dimensions?.width?.value, model.dimensions?.width?.unit.rawValue,
            model.dimensions?.height?.value, model.dimensions?.height?.unit.rawValue,
            model.weight?.value, model.weight?.unit.rawValue,
            model.color, model.inventory, model.price.value, model.actualPrice?.value,
            model.currency.rawValue, model.taxInclusive, model.taxCategory,
            Array(model.variants), model.variantId, true
        ]
    }
}
