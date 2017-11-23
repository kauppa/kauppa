import Foundation 

import KauppaCore

public struct ProductData: Codable {
    public var title: String
    public var subtitle: String
    public var description: String
    public var category: ProductCategory?
    public var size: Size?
    public var color: String?
    public var weight: UnitMeasurement<Weight>?
    public var inventory: UInt32
    public var images: [String]
    public var price: Double       // NOTE: Let's stick to one unit for now
    public var variantId: UUID?

    public init(title: String, subtitle: String, description: String) {
        self.title = title
        self.subtitle = subtitle 
        self.description = description
        self.inventory = 0
        self.images = [String]()
        self.price = 0
    }
    
    public init(title: String, subtitle: String, description: String, inventory: UInt32, images: [String], price: Double) {
        self.title = title
        self.subtitle = subtitle 
        self.description = description
        self.inventory = inventory
        self.images = images
        self.price = price
    }
}