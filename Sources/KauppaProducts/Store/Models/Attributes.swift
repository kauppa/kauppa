import Foundation

import SwiftKuery

import KauppaCore
import KauppaProductsModel

/// Table for `Attribute` model.
class Attributes: DatabaseModel<Attribute> {
    let tableName = "attributes"

    static let table = Attributes()

    let id          = Column("id", UUID.self, primaryKey: true, notNull: true, unique: true)
    let createdOn   = Column("createdOn", Timestamp.self)
    let updatedAt   = Column("updatedAt", Timestamp.self)
    let name        = Column("name", String.self)
    let type        = Column("type", String.self)
    let variants    = Column("variants", PostgresArray<String>.self)

    public override func values(from model: Attribute) -> [Any?] {
        return [
            model.id, model.createdOn, model.updatedAt, model.name,
            model.type.rawValue, model.variants
        ]
    }

    public override func create<R: DatabaseRow>(from row: R) throws -> Attribute {
        let type: String = try row.getValue(forField: self.type)
        let variants: [String]? = try? row.getValue(forField: self.variants)
        var attribute = Attribute(id: try row.getValue(forField: self.id),
                                  name: try row.getValue(forField: self.name),
                                  type: BaseType(rawValue: type)!,
                                  createdOn: try row.getValue(forField: self.createdOn),
                                  updatedAt: try row.getValue(forField: self.updatedAt))
        attribute.variants = ArraySet(variants ?? [])
        return attribute
    }
}
