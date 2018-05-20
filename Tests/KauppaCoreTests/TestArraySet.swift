import Foundation
import XCTest

@testable import KauppaCore

struct TestType: Hashable, Mappable {
    var id: UUID
    var thing: String

    public var hashValue: Int {
        return id.hashValue ^ thing.hashValue
    }

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
        let array = ArraySet([1, 2, 3])
        XCTAssertFalse(array.isEmpty)
    }

    func testArrayInsertion() {
        var array = ArraySet<Int>()
        XCTAssertFalse(array.insert(1))
        XCTAssertFalse(array.insert(2))
        XCTAssertTrue(array.insert(2))      // insert duplicate element
        XCTAssertFalse(array.isEmpty)
        XCTAssertEqual(array.count, 2)
    }

    /// Test for `mutateOnce` which should call the element matching the
    /// predicate with an `inout` closure.
    func testArrayMutationWithPredicate() {
        let id = UUID()
        var array = ArraySet([TestType(id: id, thing: "foo"),
                              TestType(id: id, thing: "bar")])
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
        let array = ArraySet([1])
        XCTAssertEqual(array[0], 1)
        XCTAssertNil(array[1])      // try out-of-bounds indexing
    }

    // Test for getting an element matching a predicate.
    func testArrayGetWithPredicate() {
        let id = UUID()
        let array = ArraySet([TestType(id: id, thing: "foo"),
                              TestType(id: id, thing: "bar")])
        let result = array.get(matching: { $0.thing == "bar" })
        XCTAssertNotNil(result)
    }

    func testArrayRemoval() {
        var array = ArraySet<Int>()
        array.insert(1)
        XCTAssertTrue(array.remove(1))      // remove the element itself
        XCTAssertFalse(array.remove(10))    // try and remove non-existent element

        array.insert(5)
        array.insert(6)
        XCTAssertEqual(array.remove(at: 0), 5)  // removes and returns the element
    }

    func testEncodable() {
        let array = ArraySet([1, 2, 3])
        let jsonData = try! JSONEncoder().encode(array)
        let string = String(data: jsonData, encoding: .utf8)!
        XCTAssertEqual(string, "[1,2,3]")
    }

    // Test for JSON decoding an array into `ArraySet`
    // (which automatically removes duplicate elements)
    func testDecodable() {
        let jsonString = "[5, 10, 15, 15, 15, 20]"
        let data = jsonString.data(using: .utf8)!
        let array = try! JSONDecoder().decode(ArraySet<Int>.self, from: data)
        XCTAssertEqual(array.inner, [5, 10, 15, 20])    // duplicates removed whilst retaining order
    }
}
