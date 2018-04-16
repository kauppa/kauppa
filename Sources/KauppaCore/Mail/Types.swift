import Foundation

/// Mail request
public struct MailRequest: Mappable {
    /// Sender's <from> address.
    public var from: String
    /// List of <to> addresses.
    public var to: [String]
    /// List of <cc> addresses.
    public var cc: [String]?
    /// List of <bcc> addresses.
    public var bcc: [String]?
    /// Subject of this mail.
    public var subject: String
    /// Body of this mail.
    public var text: String

    /// Initialize an instance with all the fields (`cc` and `bcc` being optional).
    public init(from: String, subject: String, text: String,
                to: [String] = [], cc: [String]? = nil,
                bcc: [String]? = nil)
    {
        self.from = from
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.subject = subject
        self.text = text
    }
}

/// Mail result.
public enum MailResult: Error {
    case success(Data?)
    case invalidRequest
    case serviceError(String)
}

extension MailResult {
    /// Check the equality of this result.
    public static func ==(lhs: MailResult, rhs: MailResult) -> Bool {
        switch (lhs, rhs) {
            case (.invalidRequest, .invalidRequest):
                return true
            case let (.success(d1), .success(d2)):
                return d1 == d2
            case let (.serviceError(s1), .serviceError(s2)):
                return s1 == s2
            default:
                return false
        }
    }
}
