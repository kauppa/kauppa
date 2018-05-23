import Foundation

extension Array {
    /// Initialize an array with an (optional) sequence of elements.
    public init<S>(_ sequence: S?) where S: Sequence, Element == S.Element {
        if let sequence = sequence {
            self.init(sequence)
        } else {
            self.init()
        }
    }
}
