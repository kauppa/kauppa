import Foundation

import KauppaCore
import KauppaProductsModel

public struct OrderedProduct: Encodable {
    public let data: Product?
    public let productExists: Bool
    public let processedItems: UInt8

    public init(data: Product?, productExists: Bool, processedItems: UInt8) {
        self.data = data
        self.productExists = productExists
        self.processedItems = processedItems
    }
}