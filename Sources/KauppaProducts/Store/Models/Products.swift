import Foundation

import KauppaCore
import SwiftKuery

/// Table for `Product` model.
class Products: DatabaseModel {
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

    let categories      = Column("categories", UUID.self)
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

    let variants        = Column("variants", PostgresArray<UUID>.self)
    let variantId       = Column("variantId", UUID.self)

    let active          = Column("active", Bool.self)
}
