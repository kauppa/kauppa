/// Mail request
public struct MailRequest: Mappable {
    /// Sender's <from> address.
    public var from: String
    /// List of <to> addresses.
    public var to: [String] = []
    /// List of <cc> addresses.
    public var cc: [String]? = nil
    /// List of <bcc> addresses.
    public var bcc: [String]? = nil
    /// Subject of this mail.
    public var subject: String
    /// Body of this mail.
    public var text: String
}
