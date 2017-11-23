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

public struct UnitMeasurement<T: Codable>: Codable {
    public var value: Double
    public var unit: T

    public init(value: Double, unit: T) {
        self.value = value
        self.unit = unit
    }
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
    public var height: UnitMeasurement<Length>?
    public var length: UnitMeasurement<Length>?
    public var width: UnitMeasurement<Length>?
}

public enum Weight: String, Codable {
    case milligram = "mg"
    case gram      = "g"
    case kilogram  = "kg"
    case pound     = "lb"
    // ...
}

public class WeightCounter {
    var weight = UnitMeasurement(value: 0.0, unit: Weight.gram)

    public init() {}

    public func add(_ other: UnitMeasurement<Weight>) {
        switch other.unit {
            case .milligram:
                weight.value += other.value * 0.001
            case .gram:
                weight.value += other.value
            case .kilogram:
                weight.value += other.value * 1000.0
            case .pound:
                weight.value += other.value * 453.592
        }
    }

    public func sum() -> UnitMeasurement<Weight> {
        if weight.value > 100.0 {
            weight.value /= 1000.0
            weight.unit = .kilogram
        } else if weight.value < 0.01 {
            weight.value *= 1000.0
            weight.unit = .milligram
        }

        return weight
    }
}
