import Foundation
import XCTest

@testable import KauppaTaxModel
@testable import KauppaTaxRepository

class TestTaxRepository: XCTestCase {
    static var allTests: [(String, (TestTaxRepository) -> () throws -> Void)] {
        return [
            ("Test country creation", testCountryCreation),
            ("Test country update", testCountryUpdate),
            ("Test store calls", testStoreCalls),
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
        XCTAssertTrue(store.createCalled)   // store has been called for creation
    }

    // Updating a country should change the timestamp, update cache, and should call the store.
    func testCountryUpdate() {
        let store = TestStore()
        var data = Country(name: "", taxRate: TaxRate())
        let repository = TaxRepository(withStore: store)
        try! repository.createCountry(with: data)
        data.name = "foo"
        let newData = try! repository.updateCountry(with: data)
        XCTAssertTrue(newData.createdOn != newData.updatedAt)
        // We're just testing the function calls (extensive testing is done in service)
        XCTAssertEqual(newData.name, "foo")
        XCTAssertTrue(store.updateCalled)       // update called on store
    }

    // Ensures that repository calls the store appropriately.
    func testStoreCalls() {
        let store = TestStore()
        let data = Country(name: "", taxRate: TaxRate())
        let repository = TaxRepository(withStore: store)
        try! repository.createCountry(with: data)
        repository.countries = [:]      // clear the repository
        let _ = try! repository.getCountry(id: data.id)
        XCTAssertTrue(store.getCalled)  // this should've called the store
        store.getCalled = false         // now, pretend that we never called the store
        let _ = try! repository.getCountry(id: data.id)
        // store shouldn't be called, because it was recently fetched by the repository
        XCTAssertFalse(store.getCalled)
    }
}
