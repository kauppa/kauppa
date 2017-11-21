import Foundation

public struct Measurement<T: Codable>: Codable {
    let value: Double
    let unit: T
}

public enum Length: String, Codable {
    case millimeter = "mm"
    case centimeter = "cm"
    case meter      = "m"
    case foot       = "ft"
    case inch       = "in"
    // ...
}

public struct Size: Codable {
    let height: Measurement<Length>?
    let length: Measurement<Length>?
    let width: Measurement<Length>?
}

public enum Weight: String, Codable {
    case milligram = "mg"
    case gram      = "g"
    case kilogram  = "kg"
    case pound     = "lb"
    // ...
}

public struct ProductData: Codable {
    let title: String
    let subtitle: String
    let description: String
    let size: Size?
    let color: String?
    let weight: Measurement<Weight>?
    let images: [String]
    // ...
}

public struct Product: Encodable {
    let id: UUID
    let createdOn: Date
    let updatedAt: Date
    let data: ProductData
    // ...
}
