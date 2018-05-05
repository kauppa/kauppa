/// Protocol used for decimal place rounding in `PrecisionFloat` class.
public protocol Rounding {
    static var numberOfPlaces: UInt8 { get }
}

public struct OneDecimalPlace: Rounding {
    public static let numberOfPlaces: UInt8 = 1
}

public struct TwoDecimalPlaces: Rounding {
    public static let numberOfPlaces: UInt8 = 2
}

public struct FourDecimalPlaces: Rounding {
    public static let numberOfPlaces: UInt8 = 4
}

/* Depending aliases */

public typealias Price = PrecisionFloat<TwoDecimalPlaces>
