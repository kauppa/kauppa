import XCTest

@testable import KauppaCore

class TestSender: MailServiceCallable {
    let callback: ((MailRequest) -> Void)?
    init(callback: ((MailRequest) -> Void)? = nil) {
        self.callback = callback
    }

    func sendMail(with object: MailRequest,
                  callback: @escaping (MailResult) -> Void)
    {
        callback(.success(nil))
        if let call = self.callback {
            call(object)
        }
    }
}

class TestMailService: XCTestCase {
    static var allTests: [(String, (TestMailService) -> () throws -> Void)] {
        return [
            ("SuccessfulSend", testSuccessfulSend),
            ("InvalidRequest", testInvalidRequest),
            ("OverriddenCC", testOverriddenCC)
        ]
    }

    // Test sending using a mail service. This just checks the service calls.
    func testSuccessfulSend() {
        let req = MailRequest(from: "a@foo.com",
                              subject: "Hey folks!",
                              text: "Bye", to: ["b@foo.com"],
                              cc: ["c@foo.com", "d@foo.com"],
                              bcc: ["e@foo.com"])
        let mailSend = expectation(description: "Successfully forwarded mail to sender")
        let sender = TestSender()

        sender.send(with: req, callback: { resp in
            XCTAssertNotNil(resp, "Expected mail validation to pass")
            mailSend.fulfill()
        })

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    // Test for possible errors while sending an email.
    func testInvalidRequest() {
        let tests = [
            (MailRequest(from: "", subject: "Hi!", text: "Hi!", to: ["b@foo.com"]),
             "Blocked request without 'from'"),
            (MailRequest(from: "a@foo.com", subject: "Hi!", text: "Hi!"),
             "Blocked request without 'to'"),
            (MailRequest(from: "a@foo.com", subject: "", text: "Hi!", to: ["b@foo.com"]),
             "Blocked request without 'subject'"),
            (MailRequest(from: "a@foo.com", subject: "Hi!", text: "", to: ["b@foo.com"]),
             "Blocked request without 'text'")
        ]

        let sender = TestSender()
        for (test, message) in tests {
            let expectation_ = expectation(description: message)
            sender.send(with: test, callback: { resp in
                XCTAssertTrue(resp == MailResult.invalidRequest)
                expectation_.fulfill()
            })
        }

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    // If the cc/bcc list is empty, it should be changed to `nil`
    func testOverriddenCC() {
        let req = MailRequest(from: "a@foo.com",
                              subject: "Hi!", text: "Hi!",
                              to: ["b@foo.com"],
                              cc: [], bcc: [])
        let expectation_ = expectation(description: "set cc and bcc to nil")
        let sender = TestSender(callback: { object in
            XCTAssertNil(object.cc, "Expected cc to be nil")
            XCTAssertNil(object.bcc, "Expected bcc to be nil")
            expectation_.fulfill()
        })

        sender.send(with: req, callback: { resp in
            XCTAssertNotNil(resp, "Expected mail validation to pass")
        })

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }
}
