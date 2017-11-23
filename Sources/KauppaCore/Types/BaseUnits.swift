public struct UnitMeasurement<T: Codable>: Codable {
    var value: Double
    var unit: T
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
    var height: UnitMeasurement<Length>?
    var length: UnitMeasurement<Length>?
    var width: UnitMeasurement<Length>?
}

public enum Weight: String, Codable {
    case milligram = "mg"
    case gram      = "g"
    case kilogram  = "kg"
    case pound     = "lb"
    // ...
}

class WeightCounter {
    var weight = UnitMeasurement(value: 0.0, unit: Weight.gram)

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
