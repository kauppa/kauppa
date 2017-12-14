import Foundation
import XCTest

@testable import KauppaCore

struct TestType: Equatable {
    var id: UUID
    var thing: String

    public static func ==(lhs: TestType, rhs: TestType) -> Bool {
        return lhs.id == rhs.id && lhs.thing == rhs.thing
    }
}

class TestArraySet: XCTestCase {
    static var allTests: [(String, (TestArraySet) -> () throws -> Void)] {
        return [
            ("Test array creation", testArrayCreation),
            ("Test array insertion", testArrayInsertion),
            ("Test array mutation with predicate", testArrayMutationWithPredicate),
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

    func testArrayMutationWithPredicate() {
        var array = ArraySet<TestType>()
        let id = UUID()
        XCTAssertFalse(array.insert(TestType(id: id, thing: "foo")))
        XCTAssertFalse(array.insert(TestType(id: id, thing: "bar")))
        // Even though this is a different element, our function says
        // that it's matching, so we'll call it.
        array.mutateOnce(matching: { $0.thing == "bar" }, with: { value in
            value.thing = "foobar"
        })
        XCTAssertEqual(array.inner[1].thing, "foobar")

        // This won't match the predicate, so `defaultValue` gets inserted.
        array.mutateOnce(matching: { $0.thing == "bar" }, with: { value in
            value.thing = "foobar"
        }, defaultValue: TestType(id: id, thing: "bar"))
        XCTAssertEqual(array.count, 3)
    }

    func testArrayGet() {
        var array = ArraySet<Int>()
        XCTAssertFalse(array.insert(1))
        XCTAssertEqual(array.get(from: 0), 1)
        XCTAssertNil(array.get(from: 1))    // try out-of-bounds indexing
    }

    func testArrayGetWithPredicate() {
        var array = ArraySet<TestType>()
        let id = UUID()
        XCTAssertFalse(array.insert(TestType(id: id, thing: "foo")))
        XCTAssertFalse(array.insert(TestType(id: id, thing: "bar")))
        let result = array.get(matching: { $0.thing == "bar" })
        XCTAssertNotNil(result)
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
