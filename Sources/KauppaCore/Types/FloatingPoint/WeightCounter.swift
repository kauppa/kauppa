/// A counter for adding weights
public class WeightCounter {
    private var weight = UnitMeasurement(value: 0.0, unit: Weight.gram)

    /// Initialize an empty counter.
    public init() {}

    /// Add weight to this counter.
    ///
    /// - Parameters:
    ///   - The weight to be added.
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

    /// Simplifies the final weight to an acceptable format. This should be called
    /// after adding all weights to get the result.
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
