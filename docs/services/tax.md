# KauppaTax

KauppaTax provides tax rate information for other services. It exposes `TaxServiceCallable` interface, which is implemented by both the service and the client.

## Overview

### Tax rate

All countries and regions have their own tax rates. There's a general tax rate which is applicable for any product in that country/region. If the product matches a category in that country/region, then categorical tax rate takes precedence.

When the service is queried for tax rate belonging to some address, the tax rate for the country is picked first, followed by the province and finally, the city. The general and categorical rates are overridden from top to bottom. The cumulated rate is then returned by the service. If, on the other hand, no tax rate can be applied for the given address, then the service returns an error.

**NOTE:** The service can also be configured to clamp the upper/lower limit for tax rates. If the tax rate overflows from this limit, then the service returns an error.

### Countries and Regions

The service allows you to create, update and delete countries and regions with tax rates - all of which are supposed to be gated with administrator privileges.

The flow goes like this:

 - Admin defines a country with a name and a tax rate.
 - The service returns a `UUID` for the country (if its valid).
   - If a region (province/city) in that country has a different tax rate, then the region is created for that country.
   - The service returns a `UUID` for the region (if its valid).
 - Using this ID, the country's name or tax rate can be updated.
   - In case of regions, we can update the name, tax rate, map it to another (existing) country or change its type.
 - If the country/region is no longer required, then it can be deleted using the same ID.
