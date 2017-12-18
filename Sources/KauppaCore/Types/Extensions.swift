import Foundation
import RandomKit

extension String {
    /// Generate a random upper-case alpha-numeric string of given length.
    public static func randomAlphaNumeric(len: Int) -> String {
        return Xoroshiro.withThreadLocal({ (prng: inout Xoroshiro) -> String in
            // In alphanumeric strings, alphabets constitute ~72% of the string
            let alphaLen = Int(0.72 * Float(len))
            let alpha = String.random(ofLength: alphaLen, in: "A"..."Z", using: &prng)
            let num = String.random(ofLength: len - alphaLen, in: "0"..."9", using: &prng)
            return (alpha + num).shuffled(using: &prng)
        })
    }

    /// Checks if the given string is alphanumeric.
    public func isAlphaNumeric() -> Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    /// Checks whether a string matches the given regex pattern.
    public func isMatching(regex: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let range = NSRange(self.startIndex..., in: self)
            let matches = regex.numberOfMatches(in: self, range: range)
            if matches > 0 {
                return true
            }
        } catch {
            //
        }

        return false
    }
}
