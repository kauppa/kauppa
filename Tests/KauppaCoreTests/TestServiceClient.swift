import Foundation

import XCTest

@testable import KauppaCore
@testable import TestTypes

class TestServiceClient: XCTestCase {
    static var allTests: [(String, (TestServiceClient) -> () throws -> Void)] {
        return [
            ("Test service client JSON response", testClientResponse),
            ("Test service error in JSON response", testClientServiceError),
            ("Test no data in JSON response", testClientNoData),
            ("Test invalid error code in JSON response", testClientInvalidServiceError),
            ("Test client URL parameters", testClientURLParameters),
        ]
    }

    /// Test that valid JSON response is returned in sync
    func testClientResponse() {
        var response = TestClientResponse()
        response.code = .ok
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateResponse.dateFormat
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        response.data = try! encoder.encode(DateResponse())

        let service = ServiceClient<TestClient, TestRoute>(for: "http://foo.bar")!
        var client = try! service.createClient(for: TestRoute.foo)
        XCTAssertEqual(client.url, URL(string: "/foo", relativeTo: URL(string: "http://foo.bar")!)!)
        XCTAssertEqual(client.method.rawValue, HTTPMethod.get.rawValue)
        client.response = response
        let _: DateResponse = try! service.requestJSON(with: client)
    }

    /// If the response is of non-2xx code, then the error should be decoded and thrown.
    func testClientServiceError() {
        var response = TestClientResponse()
        response.code = .badRequest
        let status = ServiceStatusMessage(error: .unknownError)
        response.data = try! JSONEncoder().encode(status)
        let service = ServiceClient<TestClient, TestRoute>(for: "http://foo.bar")!
        var client = try! service.createClient(for: TestRoute.foo)
        client.response = response

        do {
            let _: DateResponse = try service.requestJSON(with: client)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .unknownError)
        }
    }

    /// Test that absence of data in response triggers the corresponding error.
    func testClientNoData() {
        let service = ServiceClient<TestClient, TestRoute>(for: "http://foo.bar")!
        var client = try! service.createClient(for: TestRoute.foo)
        client.response = TestClientResponse()
        do {
            let _: DateResponse = try service.requestJSON(with: client)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .clientHTTPData)
        }
    }

    /// Test that invalid error code throws default error.
    func testClientInvalidServiceError() {
        var response = TestClientResponse()
        var status = ServiceStatusMessage(error: .unknownError)
        status.code = 6666
        response.data = try! JSONEncoder().encode(status)
        let service = ServiceClient<TestClient, TestRoute>(for: "http://foo.bar")!
        var client = try! service.createClient(for: TestRoute.foo)
        client.response = response

        do {
            let _: DateResponse = try service.requestJSON(with: client)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .unknownError)
        }
    }

    /// Test that the service client automatically fills URL parameters with the provided values.
    func testClientURLParameters() {
        let service = ServiceClient<TestClient, TestRoute>(for: "http://foo.bar")!
        do {
            // Should fail because we haven't given any parameters.
            let _ = try service.createClient(for: TestRoute.boo)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .missingURLParameter)
        }

        let id = UUID()
        let params = ["id": "\(id)", "booya": "yay"]
        let client = try! service.createClient(for: TestRoute.boo, with: params)
        XCTAssertEqual(client.url, URL(string: "/\(id)/yay/", relativeTo: URL(string: "http://foo.bar")!))
    }
}
