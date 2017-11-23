import XCTest

@testable import KauppaAccountsTests
@testable import KauppaOrdersTests
@testable import KauppaProductsTests
@testable import KauppaTaxTests

XCTMain([
    testCase(TestAccountsStore.allTests),
    testCase(TestOrdersStore.allTests),
    testCase(TestProductsStore.allTests),
    testCase(TestTaxService.allTests)
])
