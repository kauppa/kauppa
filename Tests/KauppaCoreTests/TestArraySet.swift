import Foundation
import XCTest

@testable import KauppaCore

class TestArraySet: XCTestCase {
    static var allTests: [(String, (TestArraySet) -> () throws -> Void)] {
        return [
            ("Test array creation", testArrayCreation),
            ("Test array insertion", testArrayInsertion),
            ("Test getting from array", testArrayGet),
            ("Test element removal from array", testArrayRemoval),
            ("Test JSON encoding", testEncodable),
            ("Test JSON decoding", testDecodable),
        ]
    }

    func testArrayCreation() {
        let array = ArraySet<Int>()
        XCTAssertTrue(array.isEmpty)
    }

    func testArrayInsertion() {
        var array = ArraySet<Int>()
        XCTAssertFalse(array.insert(1))
        XCTAssertFalse(array.insert(2))
        XCTAssertTrue(array.insert(2))      // insert duplicate element
        XCTAssertFalse(array.isEmpty)
        XCTAssertEqual(array.count, 2)
    }

    func testArrayGet() {
        var array = ArraySet<Int>()
        XCTAssertFalse(array.insert(1))
        XCTAssertEqual(array.get(from: 0), 1)
        XCTAssertNil(array.get(from: 1))    // try out-of-bounds indexing
    }

    func testArrayRemoval() {
        var array = ArraySet<Int>()
        XCTAssertFalse(array.insert(1))
        XCTAssertTrue(array.remove(1))      // remove the element itself
        XCTAssertFalse(array.remove(10))    // try and remove non-existent element

        XCTAssertFalse(array.insert(5))
        XCTAssertFalse(array.insert(6))
        XCTAssertEqual(array.remove(at: 0), 5)  // removes and returns the element
    }

    func testEncodable() {
        var array = ArraySet<Int>()
        array.inner = [1, 2, 3]
        let jsonData = try! JSONEncoder().encode(array)
        let string = String(data: jsonData, encoding: .utf8)!
        XCTAssertEqual(string, "[1,2,3]")
    }

    func testDecodable() {
        let jsonString = "[5, 10, 15]"
        let data = jsonString.data(using: .utf8)!
        let array = try! JSONDecoder().decode(ArraySet<Int>.self, from: data)
        XCTAssertEqual(array.inner, [5, 10, 15])
    }
}
