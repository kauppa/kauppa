import Foundation

/// Represents types that can be parsed from a string (inspired from `FromStr` in Rust).
/// The function is not public, because this shouldn't be called directly. Use the `parse` extension
/// for String instead. And that's because, at some point Apple will implement a protocol for this,
/// when we can get rid of this and switch to that protocol in the `parse` function.
public protocol StringParsable {
    /// Parse a value from the given string.
    static func from(string: String) -> Self?
}

extension StringParsable {
    /// Helper function to obtain the given variable from environment and parse
    /// its value into the desired type.
    ///
    /// - Parameters:
    ///   - environment: The name of the environment variable.
    /// - Returns: (Optional) parsed value.
    public static func from(environment: String) -> Self? {
        if let value = ProcessInfo.processInfo.environment[environment] {
            return value.parse()
        }

        return nil
    }
}

extension UUID: StringParsable {
    public static func from(string: String) -> UUID? {
        return UUID(uuidString: string)
    }
}

extension String: StringParsable {
    public static func from(string: String) -> String? {
        return string
    }
}

extension Int: StringParsable {
    public static func from(string: String) -> Int? {
        return Int(string)
    }
}

extension URL: StringParsable {
    public static func from(string: String) -> URL? {
        return URL(string: string)
    }
}
