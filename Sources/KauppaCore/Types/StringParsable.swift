import Foundation

/// Represents types that can be parsed from a string (inspired from `FromStr` in Rust).
/// The function is not public, because this shouldn't be called directly. Use the `parse` extension
/// for String instead. And that's because, at some point Apple will implement a protocol for this,
/// when we can get rid of this and switch to that protocol in the `parse` function.
public protocol StringParsable {
    static func from(string: String) -> Self?
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
