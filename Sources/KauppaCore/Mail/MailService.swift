import Foundation

/// Mail services should implement this protocol for use by Kauppa services.
public protocol MailServiceCallable {
    /// Send a mail with the given `MailRequest` object.
    ///
    /// - Parameters:
    ///   - with: The `MailRequest` object used for sending the mail.
    ///   - callback: The post-send callback to be called with `MailResult`
    func sendMail(with object: MailRequest,
                  callback: @escaping (MailResult) -> Void)
}

/// API that should be used for sending mails with different mailers.
/// This takes care of validating the function calls. The mailers
/// don't (shouldn't) care about the format.
extension MailServiceCallable {
    /// Default method for sending a mail after validating it. This checks
    /// for possible errors in the `MailRequest` object and passes it to
    /// the service method.
    ///
    /// - Parameters:
    ///   - with: The `MailRequest` object used for sending the mail.
    ///   - callback: The post-send callback to be called with `MailResult`
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
