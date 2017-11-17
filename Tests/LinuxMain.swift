import XCTest

@testable import KauppaOrdersTests
@testable import KauppaProductsTests
@testable import KauppaTaxTests

XCTMain([
    testCase(TestOrdersService.allTests),
    testCase(TestProductsService.allTests),
    testCase(TestTaxService.allTests)
])
