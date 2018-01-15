import Foundation
import XCTest

@testable import KauppaTaxModel
@testable import KauppaTaxRepository

class TestTaxRepository: XCTestCase {
    static var allTests: [(String, (TestTaxRepository) -> () throws -> Void)] {
        return [
            ("Test country creation", testCountryCreation),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    /// Test country creation through repository. This should cache the data and call the store.
    func testCountryCreation() {
        let store = TestStore()
        let data = Country(name: "", taxRate: TaxRate())
        let repository = TaxRepository(withStore: store)
        try! repository.createCountry(with: data)   // validation happens in service
        XCTAssertFalse(repository.countries.isEmpty)
        XCTAssertFalse(repository.countryNames.isEmpty)
        XCTAssertTrue(store.createCalled)   // store has been called for creation
    }
}
