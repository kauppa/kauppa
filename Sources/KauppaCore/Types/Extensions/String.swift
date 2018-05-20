import Foundation

extension String {
    /// Generate a random upper-case alpha-numeric string of given length.
    ///
    /// - Parameters:
    ///   - ofLength: The length of the string to be generated.
    /// - Returns: The generated string.
    public static func randomAlphaNumeric(ofLength length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let charCount = Int(letters.count)

        var randomString = ""
        for _ in 0..<length {
            let randomValue = Int(Xoroshiro.defaultGenerator.randomUInt32()) % charCount
            randomString += "\(letters[letters.index(letters.startIndex, offsetBy: randomValue)])"
        }

        return randomString
    }

    /// Checks if the given string is alphanumeric.
    ///
    /// - Returns `true` if it's alphanumeric, or `false` if it isn't.
    public func isAlphaNumeric() -> Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    /// Checks whether a string matches the given regex pattern.
    ///
    /// - Parameters:
    ///   - regex: The regex pattern used for matching the string.
    /// - Returns: `true` if it matches the pattern or `false` if it doesn't.
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

    /// Parse a string into a value of the given type.
    public func parse<T: StringParsable>() -> T? {
        return T.from(string: self)
    }
}
