import Foundation
import XCTest

@testable import KauppaCore

class TestCache: XCTestCase {
    static var allTests: [(String, (TestCache) -> () throws -> Void)] {
        return [
            ("Test dictionary cache limit", testDictionaryCache)
        ]
    }

    func testDictionaryCache() {
        var dict = DictionaryCache<Int, Int>(withCapacity: 100)
        for i in 0...110 {      // Insert 10 additional items
            dict[i] = i
        }

        XCTAssertEqual(dict.count, 100)     // final count is still 100
        dict.capacity = 50
        dict[100] = 100
        XCTAssertEqual(dict.count, 50)      // runtime capacity change
    }
}
