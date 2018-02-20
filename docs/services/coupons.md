# KauppaCoupon

KauppaCoupon keeps track of the coupons supplied to users. It exposes `CouponServiceCallable` interface, which is implemented by both the service and the client.

## Overview

### Coupon

Coupons are special products that hold money (which cannot be withdrawn later, mind you). They can be created by the product/shop owners and issued with a product in an order, or can be bought as any other product by users (with some predefined value and currency). Optionally, the owners can disable coupons, attach a note with the coupon, and can also set expiry dates for them, beyond which the coupons are invalid.

Coupons are identified using their unique 16-character alphanumeric string. Users use this code to apply coupons in their cart before checking out.

## Usage

### Initializing the service

If you're planning to use the service itself, then you'd need `KauppaCoupon` package as a whole (since the service needs the client interface, repository and store).

``` swift
import KauppaCouponRepository
import KauppaCouponService
import KauppaCouponStore

let store = ... // store of your choice
let repository = CouponRepository(with: store)
let service = CouponService(with: repository)
```

### Initializing the client

``` swift
import KauppaCouponClient

let client = CouponClient(host: "https://naamio.cloud/coupons")
client.use(token: "deadbeef")
```

Since both the service and the client implement the same protocol, the API remains the same.

### Example

``` swift
import Foundation
import KauppaCore
import KauppaCouponModel

// create a coupong with $0 balance
var coupon = try! service.createCoupon(with: CouponData())
print("\(coupon.data.code)")        // 16-char alphanumeric string
coupon = try! service.getCoupon(for: coupon.data.code)
// future queries only show the last 4 characters in the code (other 12 replaced with "X")
print("\(coupon.data.code)")

// recharge the coupon and set an expiry date
var patch = CouponPatch()
patch.balance = UnitMeasurement(value: 10.0, unit: .usd)
patch.expiresOn = Date(timeIntervalSinceNow: 87000)         // ~1 day from now
coupon = try! service.updateCoupon(for: coupon.id, with: patch)
```
