import XCTest

@testable import KauppaAccountsTests
@testable import KauppaCoreTests
@testable import KauppaOrdersTests
@testable import KauppaProductsTests
@testable import KauppaTaxTests

XCTMain([
    testCase(TestAccountsService.allTests),
    testCase(TestAccountsRepository.allTests),
    testCase(TestArraySet.allTests),
    testCase(TestCodableTypes.allTests),
    testCase(TestOrdersRepository.allTests),
    testCase(TestOrdersService.allTests),
    testCase(TestProductsRepository.allTests),
    testCase(TestProductsService.allTests),
    testCase(TestProductVariants.allTests),
    testCase(TestTaxService.allTests)
])
