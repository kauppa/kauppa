// swift-tools-version:4.0

import PackageDescription

let modelTargets: [Target] = [
    .target(
        name: "KauppaAccountsModel",
        dependencies: ["KauppaCore"],
        path: "Sources/KauppaAccounts/Model"
    ),
    .target(
        name: "KauppaOrdersModel",
        dependencies: ["KauppaCore", "KauppaProductsModel"],
        path: "Sources/KauppaOrders/Model"
    ),
    .target(
        name: "KauppaProductsModel",
        dependencies: ["KauppaCore"],
        path: "Sources/KauppaProducts/Model"
    )
]

let serviceTargets: [Target] = [
    .target(
        name: "KauppaAccountsService",
        dependencies: ["KauppaAccountsModel", "KauppaCore"],
        path: "Sources/KauppaAccounts/Service"
    )
]

let daemonTargets: [Target] = [
    .target(
        name: "KauppaAccounts",
        dependencies: ["KauppaAccountsService", "KauppaAccountsModel", "KauppaCore"],
        exclude: ["Service", "Model"]
    ),
    .target(
        name: "KauppaOrders",
        dependencies: ["KauppaOrdersModel", "KauppaCore"],
        exclude: ["Model"]
    ),
    .target(
        name: "KauppaProducts",
        dependencies: ["KauppaProductsModel", "KauppaCore"],
        exclude: ["Model"]
    ),
    .target(
        name: "KauppaTax",
        dependencies: ["KauppaCore"]
    )
]

let testTargets: [Target] = [
    .testTarget(
        name: "KauppaAccountsTests",
        dependencies: ["KauppaAccountsService", "KauppaAccountsModel", "KauppaCore"]),
    .testTarget(
        name: "KauppaOrdersTests",
        dependencies: ["KauppaOrders", "KauppaCore"]),
    .testTarget(
        name: "KauppaProductsTests",
        dependencies: ["KauppaProducts", "KauppaCore"]),
    .testTarget(
        name: "KauppaTaxTests",
        dependencies: ["KauppaTax", "KauppaCore"])
]

var targets: [Target] = [
    .target(
        name: "KauppaCore",
        dependencies: []
    )
]

targets.append(contentsOf: modelTargets)
targets.append(contentsOf: serviceTargets)
targets.append(contentsOf: daemonTargets)
targets.append(contentsOf: testTargets)

let package = Package(
    name: "Kauppa",
    products: [
        .executable(
            name: "KauppaAccounts",
            targets: ["KauppaAccounts"]
        ),
        .executable(
            name: "KauppaOrders",
            targets: ["KauppaOrders"]
        ),
        .executable(
            name: "KauppaProducts",
            targets: ["KauppaProducts"]
        ),
        .executable(
            name: "KauppaTax",
            targets: ["KauppaTax"]
        )
    ],
    dependencies: [
        
    ],
    targets: targets
)
