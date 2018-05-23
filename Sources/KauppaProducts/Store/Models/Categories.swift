import Foundation

import SwiftKuery

import KauppaCore
import KauppaProductsModel

/// Table for `Category` model.
class Categories: DatabaseModel<Category> {
    let tableName = "categories"

    static let table = Categories()

    let id          = Column("id", UUID.self, primaryKey: true, notNull: true, unique: true)
    let name        = Column("name", String.self)
    let description = Column("description", String.self)

    public override func values(from model: Category) -> [Any?] {
        return [model.id, model.name, model.description]
    }

    public override func create<R: DatabaseRow>(from row: R) throws -> Category {
        let name: String = try row.getValue(forField: self.name)
        let description: String? = try? row.getValue(forField: self.description)
        var category = Category(name: name, description: description)
        category.id = try row.getValue(forField: self.id)
        return category
    }
}
