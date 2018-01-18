import XCTest

@testable import KauppaAccountsTests
@testable import KauppaCartTests
@testable import KauppaCoreTests
@testable import KauppaCouponTests
@testable import KauppaOrdersTests
@testable import KauppaProductsTests
@testable import KauppaShipmentsTests
@testable import KauppaTaxTests

XCTMain([
    testCase(TestAccountsService.allTests),
    testCase(TestAccountsRepository.allTests),
    testCase(TestArraySet.allTests),
    testCase(TestAccountTypes.allTests),
    testCase(TestMailService.allTests),
    testCase(TestCartRepository.allTests),
    testCase(TestCartService.allTests),
    testCase(TestOrdersWithCoupons.allTests),
    testCase(TestCouponRepository.allTests),
    testCase(TestCouponService.allTests),
    testCase(TestCouponTypes.allTests),
    testCase(TestOrdersRepository.allTests),
    testCase(TestOrdersService.allTests),
    testCase(TestRefunds.allTests),
    testCase(TestReturns.allTests),
    testCase(TestShipmentUpdates.allTests),
    testCase(TestProductsRepository.allTests),
    testCase(TestProductsService.allTests),
    testCase(TestProductTypes.allTests),
    testCase(TestProductVariants.allTests),
    testCase(TestShipmentsRepository.allTests),
    testCase(TestShipmentsService.allTests),
    testCase(TestTaxRepository.allTests),
    testCase(TestTaxService.allTests),
    testCase(TestTaxTypes.allTests)
])
