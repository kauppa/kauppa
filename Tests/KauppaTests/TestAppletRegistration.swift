import Dispatch
import Kitura
import NokkaServer
import XCTest

@testable import KauppaClient
@testable import KauppaServer

class TestAppletRegistration: XCTestCase {
    let parentPlugin = AppletServer(port: 8000)
    let parentHome = "http://0.0.0.0:8000"

    let commercePlugin = CommerceAppletServer(port: 8001)
    let commercePluginClient = CommerceAppletClient(name: "commerce-master",
                                                    address: "http://0.0.0.0:8001")

    static var allTests: [(String, (TestAppletRegistration) -> () throws -> Void)] {
        return [
            ("Successful Registration", testSuccessfulRegistration),
        ]
    }

    override func setUp() {
        super.setUp()

        parentPlugin.createHTTPServer()

        DispatchQueue(label: "Request queue").async() {
            Kitura.run()
        }
    }

    override func tearDown() {
        super.tearDown()

        Kitura.stop()
    }

    func testSuccessfulRegistration() {
        let registration = expectation(description: "Registration queued")

        commercePluginClient.registerEndpoint(relUrl: "/store", hostUrl: parentHome,
                                              token: parentPlugin.authToken,
                                              callback: { token in
            XCTAssertNotNil(token, "Registration should've succeeded!")
            registration.fulfill()
        })

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
}
