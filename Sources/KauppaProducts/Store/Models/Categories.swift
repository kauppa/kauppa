import Foundation

import KauppaCore
import SwiftKuery

/// Table for `Category` model.
class Categories: DatabaseModel {
    let tableName = "categories"

    static let table = Categories()

    let id          = Column("id", UUID.self, primaryKey: true, notNull: true, unique: true)
    let name        = Column("name", String.self)
    let description = Column("description", String.self)
}
