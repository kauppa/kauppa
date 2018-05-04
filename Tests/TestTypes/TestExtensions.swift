import Foundation
import XCTest

/// Constraints required for testing approximate equality. Used only for `TestApproxEqual` function.
protocol ApproxComparable {
    static func +(lhs: Self, rhs: Double) -> Self
    static func -(lhs: Self, rhs: Double) -> Self
    static func <(lhs: Self, rhs: Self) -> Bool
    static func >(lhs: Self, rhs: Self) -> Bool
}

extension Float: ApproxComparable {
    static func +(lhs: Float, rhs: Double) -> Float {
        return lhs + Float(rhs)
    }

    static func -(lhs: Float, rhs: Double) -> Float {
        return lhs - Float(rhs)
    }
}

extension Double: ApproxComparable {}

/// Function for testing floating point values. When you see something like
/// "6.5 is not equal to 6.5", then this is what you should use for testing.
/// It ensures that the value lies within an error range rather than testing
/// exact equality.
///
/// By default, the error range is chosen to 1 part within a million. This can be
/// changed by passing the error parameter.
func TestApproxEqual<T: ApproxComparable>(_ lhs: T, _ rhs: T, error: Double = 0.000001) {
    XCTAssertTrue(lhs < (rhs + error) && lhs > (rhs - error),
                  "\(lhs) is not equal to \(rhs)")
}
