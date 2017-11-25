import Foundation

public func isValidEmail(_ email: String) -> Bool {
    do {
        let pattern = "(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$)"
        let regex = try NSRegularExpression(pattern: pattern)
        let matches = regex.numberOfMatches(in: email,
                                            range: NSRange(email.startIndex..., in: email))
        if matches > 0 {
            return true
        }
    } catch {
        //
    }

    return false
}
