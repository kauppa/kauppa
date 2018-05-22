import Foundation

import KauppaCore
import SwiftKuery

/// Table for `Attribute` model.
class Attributes: DatabaseModel {
    let tableName = "attributes"

    static let table = Attributes()

    let id          = Column("id", UUID.self, primaryKey: true, notNull: true, unique: true)
    let createdOn   = Column("createdOn", Timestamp.self)
    let updatedAt   = Column("updatedAt", Timestamp.self)
    let name        = Column("name", String.self)
    let type        = Column("type", String.self)
    let variants    = Column("variants", PostgresArray<String>.self)
}
