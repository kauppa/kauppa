/// Months
public enum Month: UInt8, Codable {
    case january   = 1
    case february  = 2
    case march     = 3
    case april     = 4
    case may       = 5
    case june      = 6
    case july      = 7
    case august    = 8
    case september = 9
    case october   = 10
    case november  = 11
    case december  = 12
}

/// Length units
public enum Length: String, Codable {
    case millimeter = "mm"
    case centimeter = "cm"
    case meter      = "m"
    case foot       = "ft"
    case inch       = "in"
    // ...
}

/// Weight units
public enum Weight: String, Codable {
    case milligram = "mg"
    case gram      = "g"
    case kilogram  = "kg"
    case pound     = "lb"
    // ...
}

/// Popular currencies
public enum Currency: String, Codable {
    case usd   = "USD"
    case euro  = "EUR"
    case pound = "GBP"
    case rupee = "INR"
    case yen   = "JPY"
    case ruble = "RUB"
}

/// Temperature units
public enum Temperature: String, Codable {
    case kelvin     = "K"
    case celsius    = "C"
    case fahrenheit = "F"
}

// Area units
public enum Area: String, Codable {
    case squareCentimeter = "sq. cm"
    case squareInch       = "sq. in"
    case squareFoot       = "sq. ft"
    case squareMeter      = "sq. m"
}

// Volume units
public enum Volume: String, Codable {
    case cubicInch  = "cu. in"
    case cubicFoot  = "cu. ft"
    case cubicMeter = "cu. m"
    case liter      = "l"
}
