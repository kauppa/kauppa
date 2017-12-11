import KauppaCore

/// Test mail service for checking mail requests raised from the orders service
public class TestMailer: MailServiceCallable {
    let callback: (MailRequest) -> Void

    public init(callback: @escaping (MailRequest) -> Void) {
        self.callback = callback
    }

    public func sendMail(with object: MailRequest,
                         callback: @escaping (MailResult) -> Void)
    {
        self.callback(object)   // actual verification is done here
        callback(MailResult.success(nil))   // always succeed
    }
}
