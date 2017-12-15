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

    public init(with service: MailServiceCallable, mailsFrom: String) {
        self.sender = mailsFrom
        self.service = service
    }

    /// Send mail with a `MailFormattable` object.
    public func sendMail(to recipient: String, with object: MailFormattable,
                         callback: PostSendCallback? = nil)
    {
        let subject = object.createMailSubject()
        let body = object.createMailDescription()
        var request = MailRequest(from: sender, subject: subject, text: body)
        request.to.append(recipient)
        service.send(with: request, callback: { result in
            if let callback = callback {
                callback(result)
            }

            // FIXME: logging?
        })
    }
}
