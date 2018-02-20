# KauppaTax

KauppaTax provides tax rate information for other services. It exposes `TaxServiceCallable` interface, which is implemented by both the service and the client.

## Overview

### Tax rate

All countries and regions have their own tax rates. There's a general tax rate which is applicable for any product in that country/region. If the product matches a category in that country/region, then categorical tax rate takes precedence.

When the service is queried for tax rate belonging to some address, the tax rate for the country is picked first, followed by the province and finally, the city. The general and categorical rates are overridden from top to bottom. The cumulated rate is then returned by the service. If, on the other hand, no tax rate can be applied for the given address, then the service returns an error.

**NOTE:** The service can also be configured to clamp the upper/lower limit for tax rates. If the tax rate overflows this limit, then the service returns an error.

### Countries and Regions

The service allows you to create, update and delete countries and regions with tax rates - all of which are supposed to be gated with administrator privileges.

The flow goes like this:

 - Admin defines a country with a name and a tax rate.
 - The service returns the data along with an `UUID` for the country (if its valid).
   - If a region (province/city) in that country has a different tax rate, then the region is created for that country.
   - The service returns the data along with an `UUID` for the region (if its valid).
 - Using this ID, the country's name or tax rate can be updated.
   - In case of regions, we can update the name, tax rate, map it to another (existing) country or change its type.
 - If the country/region is no longer required, then it can be deleted using the same ID.

## Usage

### Initializing the service

If you're planning to use the service itself, then you'd need `KauppaTax` package as a whole (since the service needs the client interface, repository and store).

``` swift
import KauppaTaxRepository
import KauppaTaxService
import KauppaTaxStore

let store = ... // store of your choice
let repository = TaxRepository(with: store)
let service = TaxService(with: repository)
```

### Initializing the client

``` swift
import KauppaTaxClient

let client = TaxClient(host: "https://naamio.cloud/tax")
client.use(token: "deadbeef")
```

Since both the service and the client implement the same protocol, the API remains the same.

### Example

``` swift
import KauppaAccountsModel
import KauppaTaxModel

var rate = TaxRate()
rate.general = 18.0     // rates in percent
rate.categories["drink"] = 5.0

// create a country
let countryData = Country(name: "India", taxRate: rate)
let country = try! service.createCountry(with: data)

rate.general = 28.0

// add a region to it
let regionData = RegionData(name: "Chennai", taxRate: rate, kind: .city)
let region = try! service.addRegion(to: country.id, data: regionData)

// query the rate for an address
var address = Address()
address.country = "India"
var rate = try! service.getTaxRate(for: address)
print("\(rate.general)")      // 18.0

address.city = "Chennai"
rate = try! service.getTaxRate(for: address)
print("\(rate.general)")      // 28.0
print("\(rate.categories)")   // { "drink": 28.0 }
```
