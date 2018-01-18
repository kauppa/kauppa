import XCTest

import KauppaTaxModel
import KauppaTaxService
import KauppaTaxRepository

class TestTaxService: XCTestCase {

    static var allTests: [(String, (TestTaxService) -> () throws -> Void)] {
        return [
            ("Test country creation", testCountryCreation),
            ("Test invalid country creation data", testCountryCreationInvalidData),
            ("Test country update", testCountryUpdate),
            ("Test invalid country update data", testCountryUpdateInvalidData),
            ("Test region creation", testRegionCreation),
            ("Test invalid region creation data", testRegionCreationInvalidData),
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
        rate.categories["food"] = 1001.0
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

    /// Check that service supports updating country data, and that it validates the patch.
    func testCountryUpdate() {
        let store = TestStore()
        let repository = TaxRepository(withStore: store)
        let service = TaxService(withRepository: repository)
        var rate = TaxRate()
        rate.general = 18.0
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

    /// Make sure that validation happens during country update in service.
    func testCountryUpdateInvalidData() {
        let store = TestStore()
        let repository = TaxRepository(withStore: store)
        let service = TaxService(withRepository: repository)
        let data = CountryData(name: "foo", taxRate: TaxRate())
        let country = try! service.createCountry(with: data)

        var cases = [(CountryPatch, TaxError)]()
        var patch = CountryPatch()
        patch.name = ""
        patch.taxRate = TaxRate()
        cases.append((patch, .invalidCountryName))
        patch.name = "foobar"
        patch.taxRate!.general = -1.0
        cases.append((patch, .invalidTaxRate))
        patch.taxRate!.general = 5.0
        patch.taxRate!.categories["food"] = 25000.0
        cases.append((patch, .invalidCategoryTaxRate("food")))

        for (testCase, error) in cases {
            do {
                let _ = try service.updateCountry(id: country.id, with: testCase)
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! TaxError, error)
            }
        }
    }

    /// Testing service support for country deletion
    func testCountryDeletion() {
        let store = TestStore()
        let repository = TaxRepository(withStore: store)
        let service = TaxService(withRepository: repository)
        let data = CountryData(name: "foo", taxRate: TaxRate())
        let country = try! service.createCountry(with: data)
        try! service.deleteCountry(id: country.id)
    }

    func testRegionCreation() {
        let store = TestStore()
        let repository = TaxRepository(withStore: store)
        let service = TaxService(withRepository: repository)
        var rate = TaxRate()
        rate.general = 18.0
        let countryData = CountryData(name: "India", taxRate: rate)
        let country = try! service.createCountry(with: countryData)
        rate.general = 28.0
        let regionData = RegionData(name: "Maharashtra", taxRate: rate, kind: .province)
        let region = try! service.addRegion(toCountry: country.id, data: regionData)
        XCTAssertEqual(region.createdOn, region.updatedAt)
        XCTAssertEqual(region.name, "Maharashtra")
        XCTAssertEqual(region.taxRate.general, 28.0)
        XCTAssertEqual(region.countryId, country.id)
        XCTAssertEqual(region.kind.rawValue, "province")
    }

    func testRegionCreationInvalidData() {
        let store = TestStore()
        let repository = TaxRepository(withStore: store)
        let service = TaxService(withRepository: repository)
        let countryData = CountryData(name: "India", taxRate: TaxRate())
        let country = try! service.createCountry(with: countryData)

        var cases = [(RegionData, TaxError)]()
        var rate = TaxRate()
        cases.append((RegionData(name: "", taxRate: rate, kind: .city), .invalidRegionName))
        rate.general = -1.0
        cases.append((RegionData(name: "Chennai", taxRate: rate, kind: .city), .invalidTaxRate))
        rate.general = 5.0
        rate.categories["food"] = 1500.0
        cases.append((RegionData(name: "Mumbai", taxRate: rate, kind: .city),
                      .invalidCategoryTaxRate("food")))

        do {    // random UUID for country - invalid
            let _ = try service.addRegion(toCountry: UUID(), data: cases[0].0)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! TaxError, .invalidCountryId)
        }

        for (testCase, error) in cases {
            do {
                let _ = try service.addRegion(toCountry: country.id, data: testCase)
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! TaxError, error)
            }
        }
    }
}
