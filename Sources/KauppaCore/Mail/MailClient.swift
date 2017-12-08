/// Represents a type that can provide the subject and body of an email.
public protocol MailFormattable {
    /// Create the mail subject from the given object.
    func createMailSubject() -> String

    /// Create the body of the mail from the given object.
    func createMailDescription() -> String
}

/// Mail services should implement this protocol for use by Kauppa services.
public protocol MailServiceCallable {
    /// Send a mail with the given `MailRequest` object.
    func sendMail(with object: MailRequest,
                  callback: @escaping (Data?) -> Void)
}

/// Callback called after sending mail.
public typealias PostSendCallback: (Data?) -> Void

/// Mail client used for sending mails.
public class MailClient {
    let sender: String
    let service: MailServiceCallable

    public init(withService: MailServiceCallable, mailsFrom: String) {
        sender = mailsFrom
        service = withService
    }

    public func sendMail(to recipient: String, with object: MailFormattable,
                         callback: PostSendCallback? = nil)
    {
        var request = MailRequest()
        request.from = sender
        request.to.append(recipient)
        request.subject = object.createMailSubject()
        request.text = object.createMailDescription()
        service.sendMail(with: request, callback: { result in
            if let callback = callback {
                callback(result)
            }

            // logging
        })
    }
}
