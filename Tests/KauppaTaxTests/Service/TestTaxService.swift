import XCTest

import KauppaTaxModel
import KauppaTaxService
import KauppaTaxRepository

class TestTaxService: XCTestCase {

    static var allTests: [(String, (TestTaxService) -> () throws -> Void)] {
        return [
            ("Test country creation", testCountryCreation),
            ("Test invalid country data", testCountryCreationInvalidData),
            ("Test country update", testCountryUpdate),
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

    /// Ensure that invalid country data is rejected by the service.
    func testCountryCreationInvalidData() {
        let store = TestStore()
        let repository = TaxRepository(withStore: store)
        let service = TaxService(withRepository: repository)

        var cases = [(CountryData, TaxError)]()
        var rate = TaxRate()
        cases.append((CountryData(name: "", taxRate: rate), .invalidCountryName))
        rate.general = -1.0
        cases.append((CountryData(name: "India", taxRate: rate), .invalidTaxRate))
        rate.general = 5.0
        rate.categories["food"] = 150.0
        cases.append((CountryData(name: "India", taxRate: rate), .invalidCategoryTaxRate("food")))

        for (testCase, error) in cases {
            do {
                let _ = try service.createCountry(with: testCase)
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! TaxError, error)
            }
        }
    }

    /// Service supports updating country data.
    func testCountryUpdate() {
        let store = TestStore()
        let repository = TaxRepository(withStore: store)
        let service = TaxService(withRepository: repository)
        var rate = TaxRate()
        rate.general = 18.0
        rate.categories["drink"] = 5.0
        let data = CountryData(name: "India", taxRate: rate)
        let country = try! service.createCountry(with: data)

        var patch = CountryPatch()
        patch.name = "Finland"
        rate.general = 14.0
        rate.categories = [:]
        patch.taxRate = rate
        let newData = try! service.updateCountry(id: country.id, with: patch)
        XCTAssertEqual(newData.name, "Finland")
        XCTAssertEqual(newData.taxRate.general, 14.0)
        XCTAssertTrue(newData.taxRate.categories.isEmpty)
    }
}
