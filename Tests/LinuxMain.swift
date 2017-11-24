import XCTest

@testable import KauppaAccountsTests
@testable import KauppaOrdersTests
@testable import KauppaProductsTests
@testable import KauppaTaxTests

XCTMain([
    testCase(TestAccountsService.allTests),
    testCase(TestOrdersRepository.allTests),
    testCase(TestProductsRepository.allTests),
    testCase(TestTaxService.allTests)
])
