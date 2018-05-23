import Foundation

import SwiftKuery

import KauppaCore
import KauppaProductsModel

/// Table for `AttributeValue` model.
class AttributeValueTable: DatabaseModel<CustomAttribute> {
    let tableName = "attribute_values"

    static let table = AttributeValueTable()

    let attributeId = Column("attribute_id", UUID.self)
    let entityId    = Column("entity_id", UUID.self)
    let stringValue = Column("string_value", String.self)
    let boolValue   = Column("bool_value", Bool.self)
    let intValue    = Column("int_value", Int32.self)
    let floatValue  = Column("float_value", Float.self)
    let unit        = Column("unit", String.self)

    public override func values(from model: CustomAttribute) -> [Any?] {
        var values: [Any?] = [model.id!, nil, "", false, 0, 0.0, model.unit ?? ""]  // defaults
        switch model.type! {
            case .string, .enum_:
                values[2] = model.value
            case .boolean:
                values[3] = model.type!.parse(value: model.value)!
            case .number:
                values[4] = model.type!.parse(value: model.value)!
            default:
                values[5] = model.type!.parse(value: model.value)!
        }

        return values
    }
}
