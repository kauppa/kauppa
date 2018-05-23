import Foundation

import SwiftKuery

import KauppaCore
import KauppaProductsModel

/// Table for `Product` model.
class Products: DatabaseModel<Product> {

    let tableName = "products"

    static let table = Products()

    let id              = Column("id", UUID.self, primaryKey: true, notNull: true, unique: true)
    let createdOn       = Column("createdOn", Timestamp.self, notNull: true)
    let updatedAt       = Column("updatedAt", Timestamp.self, notNull: true)

    let title           = Column("title", String.self, notNull: true)
    let subtitle        = Column("subtitle", String.self)
    let description     = Column("description", String.self)
    let overview        = Column("overview", String.self)
    let images          = Column("images", PostgresArray<String>.self)

    let categories      = Column("categories", PostgresArray<UUID>.self)
    let tags            = Column("tags", PostgresArray<String>.self)

    let lengthValue     = Column("lengthValue", Float.self)
    let lengthUnit      = Column("lengthUnit", String.self)
    let widthValue      = Column("widthValue", Float.self)
    let widthUnit       = Column("widthUnit", String.self)
    let heightValue     = Column("heightValue", Float.self)
    let heightUnit      = Column("heightUnit", String.self)
    let weightValue     = Column("weightValue", Float.self)
    let weightUnit      = Column("weightUnit", String.self)
    let color           = Column("color", String.self)

    let inventory       = Column("inventory", Int16.self, notNull: true)
    let price           = Column("price", Float.self, notNull: true)
    let actualPrice     = Column("actualPrice", Float.self)
    let currency        = Column("currency", String.self, notNull: true)
    let taxInclusive    = Column("taxInclusive", Bool.self)
    let taxCategory     = Column("taxCategory", String.self)

    let variants        = Column("variants", PostgresArray<UUID>.self)
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
