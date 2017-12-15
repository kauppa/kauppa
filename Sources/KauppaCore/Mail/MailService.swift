import Foundation

/// Mail services should implement this protocol for use by Kauppa services.
public protocol MailServiceCallable {
    /// Send a mail with the given `MailRequest` object.
    func sendMail(with object: MailRequest,
                  callback: @escaping (MailResult) -> Void)
}

/// API that should be used for sending mails with different mailers.
/// This takes care of validating the function calls. The mailers
/// don't (shouldn't) care about the format.
extension MailServiceCallable {
    public func send(with mailRequest: MailRequest,
                     callback: @escaping (MailResult) -> Void)
    {
        var object = mailRequest
        if (object.from.isEmpty || object.to.isEmpty
            || object.subject.isEmpty || object.text.isEmpty)
        {
            return callback(.invalidRequest)
        }

        if let cc = object.cc {
            if cc.isEmpty {
                object.cc = nil
            }
        }

        if let bcc = object.bcc {
            if bcc.isEmpty {
                object.bcc = nil
            }
        }

        self.sendMail(with: object, callback: callback)
    }
}
