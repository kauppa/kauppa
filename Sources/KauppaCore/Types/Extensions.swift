import Foundation

extension String {
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
