import XCTest

import KauppaCore
@testable import KauppaAccountsModel
@testable import KauppaTaxModel
import KauppaTaxService
import KauppaTaxRepository

class TestTaxService: XCTestCase {

    static var allTests: [(String, (TestTaxService) -> () throws -> Void)] {
        return [
            ("Test country creation", testCountryCreation),
            ("Test tax calculation for country", testTaxCalculationCountry),
            ("Test invalid country creation data", testCountryCreationInvalidData),
            ("Test country update", testCountryUpdate),
            ("Test invalid country update data", testCountryUpdateInvalidData),
            ("Test country deletion", testCountryDeletion),
            ("Test region creation", testRegionCreation),
            ("Test tax calculation for region", testTaxCalculationRegion),
            ("Test invalid region creation data", testRegionCreationInvalidData),
            ("Test region update", testRegionUpdate),
            ("Test invalid region update data", testRegionUpdateInvalidData),
            ("Test region deletion", testRegionDeletion),
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
        let repository = TaxRepository(with: store)
        let service = TaxService(with: repository)
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

    /// Check that the service returns the right tax rate for a country.
    func testTaxCalculationCountry() {
        let store = TestStore()
        let repository = TaxRepository(with: store)
        let service = TaxService(with: repository)
        var rate = TaxRate()
        rate.general = 18.0
        let data = CountryData(name: "India", taxRate: rate)
        let _ = try! service.createCountry(with: data)
        var address = Address()
        do {    // no country - error
            let _ = try service.getTaxRate(for: address)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .noMatchingCountry)
        }

        address.country = "India"
        let taxRate = try! service.getTaxRate(for: address)
        XCTAssertEqual(taxRate.general, 18.0)
    }

    /// Ensure that invalid country data is rejected by the service.
    func testCountryCreationInvalidData() {
        let store = TestStore()
        let repository = TaxRepository(with: store)
        let service = TaxService(with: repository)

        var cases = [(CountryData, ServiceError)]()
        var rate = TaxRate()
        cases.append((CountryData(name: "", taxRate: rate), .invalidCountryName))
        rate.general = -1.0
        cases.append((CountryData(name: "India", taxRate: rate), .invalidTaxRate))
        rate.general = 5.0
        rate.categories["food"] = 1001.0
        cases.append((CountryData(name: "India", taxRate: rate), .invalidCategoryTaxRate))

        for (testCase, error) in cases {
            do {
                let _ = try service.createCountry(with: testCase)
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }

    /// Check that service supports updating country data, and that it validates the patch.
    func testCountryUpdate() {
        let store = TestStore()
        let repository = TaxRepository(with: store)
        let service = TaxService(with: repository)
        var rate = TaxRate()
        rate.general = 18.0
        let data = CountryData(name: "India", taxRate: rate)
        let country = try! service.createCountry(with: data)

        var patch = CountryPatch()
        patch.name = "Finland"
        rate.general = 14.0
        patch.taxRate = rate
        let newData = try! service.updateCountry(for: country.id, with: patch)
        XCTAssertEqual(newData.name, "Finland")
        XCTAssertEqual(newData.taxRate.general, 14.0)
        XCTAssertTrue(newData.taxRate.categories.isEmpty)
    }

    /// Make sure that validation happens during country update in service.
    func testCountryUpdateInvalidData() {
        let store = TestStore()
        let repository = TaxRepository(with: store)
        let service = TaxService(with: repository)
        let data = CountryData(name: "foo", taxRate: TaxRate())
        let country = try! service.createCountry(with: data)

        var cases = [(CountryPatch, ServiceError)]()
        var patch = CountryPatch()
        patch.name = ""
        patch.taxRate = TaxRate()
        cases.append((patch, .invalidCountryName))
        patch.name = "foobar"
        patch.taxRate!.general = -1.0
        cases.append((patch, .invalidTaxRate))
        patch.taxRate!.general = 5.0
        patch.taxRate!.categories["food"] = 25000.0
        cases.append((patch, .invalidCategoryTaxRate))

        for (testCase, error) in cases {
            do {
                let _ = try service.updateCountry(for: country.id, with: testCase)
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }

    /// Testing service support for country deletion
    func testCountryDeletion() {
        let store = TestStore()
        let repository = TaxRepository(with: store)
        let service = TaxService(with: repository)
        let data = CountryData(name: "foo", taxRate: TaxRate())
        let country = try! service.createCountry(with: data)
        try! service.deleteCountry(for: country.id)
    }

    /// Testing service support for region creation
    func testRegionCreation() {
        let store = TestStore()
        let repository = TaxRepository(with: store)
        let service = TaxService(with: repository)
        var rate = TaxRate()
        rate.general = 18.0
        let countryData = CountryData(name: "India", taxRate: rate)
        let country = try! service.createCountry(with: countryData)
        rate.general = 28.0
        let regionData = RegionData(name: "Maharashtra", taxRate: rate, kind: .province)
        let region = try! service.addRegion(to: country.id, using: regionData)
        XCTAssertEqual(region.createdOn, region.updatedAt)
        XCTAssertEqual(region.name, "Maharashtra")
        XCTAssertEqual(region.taxRate.general, 28.0)
        XCTAssertEqual(region.countryId, country.id)
        XCTAssertEqual(region.kind.rawValue, "province")
    }

    /// Check that the service returns the right tax rate for a region. It should propagate
    /// tax rates for categories in hierarchy.
    ///
    /// NOTE: These values are hypothetical
    func testTaxCalculationRegion() {
        let store = TestStore()
        let repository = TaxRepository(with: store)
        let service = TaxService(with: repository)
        var rate = TaxRate()
        rate.general = 14.0
        // assume that there's a general tax rate for electronics throughout the country
        rate.categories["electronics"] = 20.0
        let data = CountryData(name: "India", taxRate: rate)
        let country = try! service.createCountry(with: data)
        rate = TaxRate()
        rate.general = 18.0
        rate.categories["food"] = 19.0      // this province has some tax rate for food
        rate.categories["drink"] = 15.0     // ... and drink
        var regionData = RegionData(name: "Maharashtra", taxRate: rate, kind: .province)
        let _ = try! service.addRegion(to: country.id, using: regionData)
        rate = TaxRate()
        rate.general = 28.0
        rate.categories["drink"] = 20.0     // this city has a special tax rate for drinks
        regionData = RegionData(name: "Mumbai", taxRate: rate, kind: .city)
        let _ = try! service.addRegion(to: country.id, using: regionData)

        var address = Address()
        address.city = "Mumbai"
        address.province = "Maharashtra"
        address.country = "India"
        var taxRate = try! service.getTaxRate(for: address)
        XCTAssertEqual(taxRate.general, 28.0)                       // (from city)
        XCTAssertEqual(taxRate.categories["drink"]!, 20.0)          // (from city)
        XCTAssertEqual(taxRate.categories["food"]!, 19.0)           // (from province)
        XCTAssertEqual(taxRate.categories["electronics"], 20.0)     // (from country)

        // similarly, get the tax rate for the province
        address.city = "Pune"
        taxRate = try! service.getTaxRate(for: address)
        XCTAssertEqual(taxRate.general, 18.0)                       // (from province)
        XCTAssertEqual(taxRate.categories["drink"]!, 15.0)          // (from province)
        XCTAssertEqual(taxRate.categories["food"]!, 19.0)           // (from province)
        XCTAssertEqual(taxRate.categories["electronics"], 20.0)     // (from country)
    }

    /// Test region creation with possible error cases.
    func testRegionCreationInvalidData() {
        let store = TestStore()
        let repository = TaxRepository(with: store)
        let service = TaxService(with: repository)
        let countryData = CountryData(name: "India", taxRate: TaxRate())
        let country = try! service.createCountry(with: countryData)

        var cases = [(RegionData, ServiceError)]()
        var rate = TaxRate()
        cases.append((RegionData(name: "", taxRate: rate, kind: .city), .invalidRegionName))
        rate.general = -1.0
        cases.append((RegionData(name: "Chennai", taxRate: rate, kind: .city), .invalidTaxRate))
        rate.general = 5.0
        rate.categories["food"] = 1500.0
        cases.append((RegionData(name: "Mumbai", taxRate: rate, kind: .city),
                      .invalidCategoryTaxRate))

        do {    // random UUID for country - invalid
            let _ = try service.addRegion(to: UUID(), using: cases[0].0)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .invalidCountryId)
        }

        for (testCase, error) in cases {
            do {
                let _ = try service.addRegion(to: country.id, using: testCase)
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }

    /// Test that service supports updating regions.
    func testRegionUpdate() {
        let store = TestStore()
        let repository = TaxRepository(with: store)
        let service = TaxService(with: repository)
        let countryData = CountryData(name: "foo", taxRate: TaxRate())
        let country = try! service.createCountry(with: countryData)
        let regionData = RegionData(name: "baz", taxRate: TaxRate(), kind: .province)
        let region = try! service.addRegion(to: country.id, using: regionData)

        var patch = RegionPatch()
        patch.name = "foobar"
        patch.kind = .city
        patch.taxRate = TaxRate()
        patch.taxRate!.general = 20.0
        patch.taxRate!.categories["electronics"] = 25.0
        let newData = try! service.updateRegion(for: region.id, with: patch)
        XCTAssertEqual(newData.name, "foobar")
        XCTAssertEqual(newData.taxRate.general, 20.0)
        XCTAssertEqual(newData.taxRate.categories["electronics"]!, 25.0)
        XCTAssertEqual(newData.kind.rawValue, "city")
    }

    /// Test region update call for possible error cases.
    func testRegionUpdateInvalidData() {
        let store = TestStore()
        let repository = TaxRepository(with: store)
        let service = TaxService(with: repository)
        let countryData = CountryData(name: "foo", taxRate: TaxRate())
        let country = try! service.createCountry(with: countryData)
        let regionData = RegionData(name: "baz", taxRate: TaxRate(), kind: .province)
        let region = try! service.addRegion(to: country.id, using: regionData)

        var cases = [(RegionPatch, ServiceError)]()
        var patch = RegionPatch()
        patch.name = ""
        patch.taxRate = TaxRate()
        cases.append((patch, .invalidRegionName))
        patch.name = "foobar"
        patch.taxRate!.general = -1.0
        cases.append((patch, .invalidTaxRate))
        patch.taxRate!.general = 10.0
        patch.taxRate!.categories["drink"] = 1001.0
        cases.append((patch, .invalidCategoryTaxRate))
        patch.taxRate!.categories = [:]
        patch.countryId = UUID()
        cases.append((patch, .invalidCountryId))

        for (testCase, error) in cases {
            do {
                let _ = try service.updateRegion(for: region.id, with: testCase)
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }

    /// Test that service supports deleting regions.
    func testRegionDeletion() {
        let store = TestStore()
        let repository = TaxRepository(with: store)
        let service = TaxService(with: repository)
        let data = CountryData(name: "foo", taxRate: TaxRate())
        let country = try! service.createCountry(with: data)
        let regionData = RegionData(name: "baz", taxRate: TaxRate(), kind: .province)
        let region = try! service.addRegion(to: country.id, using: regionData)
        try! service.deleteRegion(for: region.id)
    }
}
