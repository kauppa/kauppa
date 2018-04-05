# KauppaAccounts

KauppaAccounts manages account information for other services. It exposes `AccountsServiceCallable` interface, which is implemented by both the service and the client.

## Overview

### Account

Every account has a name, a list of emails, phone numbers and addresses (with optional labels) - **all properties are validated while creating an account**. The emails and phone numbers are *verifiable* (without verification, the account's actions are limited - for example, it cannot place orders).

The account service is used by cart service (for keeping track of user's cart), coupon service (for managing coupons) and orders service (for placing orders).

Once created, an account is given an `UUID`. This should then be used to get/update/delete the account.

## Usage

### Initializing the service

If you're planning to use the service itself, then you'd need `KauppaAccounts` package as a whole (since the service needs the client interface, repository and store).

``` swift
import KauppaAccountsRepository
import KauppaAccountsService
import KauppaAccountsStore

let store = ... // store of your choice
let repository = AccountsRepository(with: store)
let service = AccountsService(with: repository)
```

### Initializing the client

``` swift
import KauppaAccountsClient

let client = AccountsClient(host: "https://naamio.cloud/accounts")
client.use(token: "deadbeef")
```

Since both the service and the client implement the same protocol, the API stays the same.

### Example

``` swift
import KauppaAccountsModel

var data = AccountData()
data.name = "Sherlock"
data.emails = ["admin@sherlock-holmes.co.uk"]

// create an account
var account = try! service.createAccount(with: data)
// verify an email (note that this should be done by another service
// because Kauppa doesn't care about authentication).
try! service.verifyEmail("admin@sherlock-holmes.co.uk")

// Kauppa checks for unique email addresses. It doesn't allow us to create another account
// with the same email address.
let _nil = try? service.createAccount(with: data)   // nil

// update our name
var namePatch = AccountPatch()
namePatch.name = "Sherlock Holmes"
account = try! service.updateAccount(for: account.id, with: namePatch)
print("\(account.name)")    // Sherlock Holmes

var address = Address()
address.name = "Sherlock Holmes"
address.line1 = "221b, Baker Street"
address.province = "Marylebone"
address.city = "London"
address.country = "United Kingdom"
address.code = "NW1 6XE"

// add a new address
var addressPatch = AccountPropertyAdditionPatch()
addressPatch.address = address
account = try! service.addAccountProperty(to: account.id, using: addressPatch)
```
