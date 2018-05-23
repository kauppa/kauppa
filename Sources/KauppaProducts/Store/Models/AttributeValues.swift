import Foundation

import SwiftKuery

import KauppaCore
import KauppaProductsModel

/// Table for `AttributeValue` model.
class AttributeValues: DatabaseModel<CustomAttribute> {
    let tableName = "attribute_values"

    static let table = AttributeValues()

    let attributeId = Column("attributeId", UUID.self)
    let entityId    = Column("entityId", UUID.self)
    let stringValue = Column("stringValue", String.self)
    let boolValue   = Column("boolValue", Bool.self)
    let intValue    = Column("intValue", Int32.self)
    let floatValue  = Column("floatValue", Float.self)
    let unit        = Column("unit", String.self)

    public override func values(from model: CustomAttribute) -> [Any?] {
        var values: [Any?] = [model.id!, nil, "", false, 0, 0.0, ""]    // set defaults
        switch model.type! {
            case .string, .enum_:
                values[2] = model.value
            case .boolean:
                values[3] = Bool(model.value)!
            case .number:
                values[4] = UInt32(model.value)!
            default:
                values[5] = Float32(model.value)!
        }

        values[6] = model.unit ?? ""
        return values
    }
}
