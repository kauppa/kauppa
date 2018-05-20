import XCTest

@testable import KauppaAccountsTests
@testable import KauppaCartTests
@testable import KauppaCoreTests
@testable import KauppaCouponTests
@testable import KauppaNaamioTests
@testable import KauppaOrdersTests
@testable import KauppaProductsTests
@testable import KauppaShipmentsTests
@testable import KauppaTaxTests

XCTMain([
    testCase(TestAccountsService.allTests),
    testCase(TestAccountsRepository.allTests),
    testCase(TestAccountTypes.allTests),

    testCase(TestArraySet.allTests),
    testCase(TestCache.allTests),
    testCase(TestCoreTypes.allTests),
    testCase(TestDatabase.allTests),
    testCase(TestMailService.allTests),
    testCase(TestRouting.allTests),
    testCase(TestServiceClient.allTests),

    testCase(TestCartRepository.allTests),
    testCase(TestCartService.allTests),
    testCase(TestCartTypes.allTests),

    testCase(TestOrdersRepository.allTests),
    testCase(TestOrdersService.allTests),
    testCase(TestOrdersWithCoupons.allTests),
    testCase(TestRefunds.allTests),
    testCase(TestReturns.allTests),
    testCase(TestShipmentUpdates.allTests),

    testCase(TestCouponRepository.allTests),
    testCase(TestCouponService.allTests),
    testCase(TestCouponTypes.allTests),

    testCase(TestNaamioBridgeService.allTests),

    testCase(TestProductsRepository.allTests),
    testCase(TestProductsService.allTests),
    testCase(TestProductTypes.allTests),
    testCase(TestProductVariants.allTests),
    testCase(TestProductAttributes.allTests),

    testCase(TestShipmentsRepository.allTests),
    testCase(TestShipmentsService.allTests),

    testCase(TestTaxRepository.allTests),
    testCase(TestTaxService.allTests),
    testCase(TestTaxTypes.allTests)
])
