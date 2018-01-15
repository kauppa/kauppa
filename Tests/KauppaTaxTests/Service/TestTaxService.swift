import XCTest

import KauppaTaxModel
import KauppaTaxService
import KauppaTaxRepository

class TestTaxService: XCTestCase {

    static var allTests: [(String, (TestTaxService) -> () throws -> Void)] {
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

    /// Check that service can create country with valid tax rate.
    func testCountryCreation() {
        let store = TestStore()
        let repository = TaxRepository(withStore: store)
        let service = TaxService(withRepository: repository)
        var rate = TaxRate()
        rate.general = 18.0
        rate.categories["drink"] = 5.0
        let data = CountryData(name: "India", taxRate: rate)
        let country = try! service.createCountry(with: data)
        XCTAssertEqual(country.createdOn, country.updatedAt)
        XCTAssertEqual(country.name, "India")
        XCTAssertEqual(country.taxRate.general, 18.0)
        XCTAssertEqual(country.taxRate.categories["drink"]!, 5.0)
    }
}
