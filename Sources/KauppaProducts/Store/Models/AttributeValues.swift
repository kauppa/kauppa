import Foundation

import KauppaCore
import SwiftKuery

/// Table for `AttributeValue` model.
class AttributeValues: DatabaseModel {
    let tableName = "attribute_values"

    static let table = AttributeValues()

    let attributeId = Column("attributeId", UUID.self)
    let entityId    = Column("entityId", UUID.self)
    let stringValue = Column("stringValue", String.self)
    let boolValue   = Column("boolValue", Bool.self)
    let intValue    = Column("intValue", Int32.self)
    let floatValue  = Column("floatValue", Float.self)
    let unit        = Column("unit", String.self)
}
