# KauppaProducts

KauppaProducts manages the product and collection information. It exposes `ProductsServiceCallable` interfacce, which is implemented by both the client and the service.

## Overview

### Product

Products should be managed by the admin. A product has a number of properties to identify/distinguish it, such as title, description, category, weight, inventory count, images, price, variants, etc.

When adding a product, the admin can specify whether the price of the product is inclusive/exclusive of tax. If it's inclusive, then the tax rate for that region is obtained from the tax service and the tax is stripped off the product price. If the product is a variant of an existing product, then it's added
to the parent product's list of variants.

All properties can be updated later using the product's ID.

### Product collection

A number of products can be grouped together to form a collection. A collection has an ID, name and a description. Products can be added to (or removed from) the collection.

# Usage

### Initializing the service

If you're planning to use the service itself, then you'd need `KauppaTax` package as a whole (since the service needs the client interface, repository and store), and a client/service/anything that implements `TaxServiceCallable` (since this service needs to show product price with taxes based on regions).

``` swift
import KauppaProductsRepository
import KauppaProductsService
import KauppaProductsStore

let store = ... // store of your choice
let repository = ProductsRepository(with: store)
let service = ProductsService(with: repository,
                              // anything that implements `TaxServiceCallable`
                              taxService: ...)
```

### Initializing the client

``` swift
import KauppaProductsClient

let client = ProductsClient(host: "https://naamio.cloud/products")
client.use(token: "deadbeef")
```

Since both the service and the client implement the same protocol, the API remains the same.

### Example (products)

``` swift
import KauppaProductsModel

var address = Address()
address.country = "India"     // tax service should return a tax rate for this
var data = ProductData(title: "foo", subtitle: "bar", description: "baz")
data.price = UnitMeasurement(value: 10.0, unit: .usd)
// create a product
let product1 = try! service.createProduct(with: data, from: address)

data.variantId = product1.id
data.price!.value = 12.5
data.color = "#000"
// create a variant for that product
var product2 = try! service.createProduct(with: data, from: address)

var patch = ProductPatch()
patch.description = "baz (black)"
// update second product
product2 = try! service.updateProduct(for: product2.id, with: patch, from: address)
```

### Example (product collections)

``` swift
import KauppaProductsModel

// create a new collection
let products = [id1, id2, id3]    // should be valid products
let data = ProductCollectionData(name: "coffee beginner",
                                 description: "coffee for beginners to try out",
                                 products: products)
var collection = try! service.createCollection(with: data)

// add another product to collection
var patch = ProductCollectionItemPatch()
patch.product = id4
collection = try! service.addProduct(to: collection.id, using: patch)
// remove a product from collection
patch.product = id1
collection = try! service.removeProduct(from: collection.id, using: patch)
```
