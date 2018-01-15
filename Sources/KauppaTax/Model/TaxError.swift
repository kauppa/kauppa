import Foundation

/// Tax service errors
public enum TaxError: Error {
    case invalidTaxRate
    case invalidCategoryTaxRate(String)
    case invalidCountryName
}

extension TaxError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .invalidTaxRate:
                return "Invalid tax rate in input data"
            case .invalidCategoryTaxRate(let category):
                return "Invalid tax rate for category '\(category)' in input"
            case .invalidCountryName:
                return "Invalid name for country"
        }
    }
}

extension TaxError {
    /// Check the equality of this result.
    public static func ==(lhs: TaxError, rhs: TaxError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidTaxRate, .invalidTaxRate),
                 (.invalidCountryName, .invalidCountryName):
                return true
            case (.invalidCategoryTaxRate(let s1), .invalidCategoryTaxRate(let s2)):
                return s1 == s2
            default:
                return false
        }
    }
}
