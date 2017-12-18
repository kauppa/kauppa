import XCTest

@testable import KauppaAccountsTests
@testable import KauppaCartTests
@testable import KauppaCoreTests
@testable import KauppaGiftsTests
@testable import KauppaOrdersTests
@testable import KauppaProductsTests
@testable import KauppaTaxTests

XCTMain([
    testCase(TestAccountsService.allTests),
    testCase(TestAccountsRepository.allTests),
    testCase(TestArraySet.allTests),
    testCase(TestAccountTypes.allTests),
    testCase(TestMailService.allTests),
    testCase(TestCartRepository.allTests),
    testCase(TestCartService.allTests),
    testCase(TestGiftsRepository.allTests),
    testCase(TestGiftsService.allTests),
    testCase(TestGiftsTypes.allTests),
    testCase(TestOrdersRepository.allTests),
    testCase(TestOrdersService.allTests),
    testCase(TestProductsRepository.allTests),
    testCase(TestProductsService.allTests),
    testCase(TestProductTypes.allTests),
    testCase(TestProductVariants.allTests),
    testCase(TestTaxService.allTests)
])
