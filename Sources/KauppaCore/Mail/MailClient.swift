import Foundation

/// Represents a type that can provide the subject and body of an email.
public protocol MailFormattable {
    /// Create the mail subject from the given object.
    func createMailSubject() -> String

    /// Create the body of the mail from the given object.
    func createMailDescription() -> String
}

/// Callback called after sending mail.
public typealias PostSendCallback = (MailResult) -> Void

/// Mail client used for sending mails.
public class MailClient {
    let sender: String
    let service: MailServiceCallable

    /// Initialize the mail client with a mail service.
    ///
    /// - Parameters:
    ///   - service: Anything that implements `MailServiceCallable`
    ///   - mailsFrom: Sender for mails.
    public init(with service: MailServiceCallable, mailsFrom: String) {
        self.sender = mailsFrom
        self.service = service
    }

    /// Send mail with a `MailFormattable` object.
    ///
    /// - Parameters:
    ///   - to: The list of recipients to whom the mail is to be sent.
    ///   - with: The object implementing `MailFormattable` which decides the content of the mail.
    ///   - callback: The (optional) callback which is called with the `MailResult` from the service.
    public func sendMail(to recipients: [String], with object: MailFormattable,
                         callback: PostSendCallback? = nil)
    {
        let subject = object.createMailSubject()
        let body = object.createMailDescription()
        var request = MailRequest(from: sender, subject: subject, text: body)
        request.to = recipients
        service.send(with: request, callback: { result in
            if let callback = callback {
                callback(result)
            }

            // FIXME: logging?
        })
    }
}
