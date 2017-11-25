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

let repositoryTargets: [Target] = [
    .target(
        name: "KauppaAccountsRepository",
        dependencies: ["KauppaAccountsModel", "KauppaCore"],
        path: "Sources/KauppaAccounts/Repository"
    ),
    .target(
        name: "KauppaOrdersRepository",
        dependencies: ["KauppaOrdersModel", "KauppaCore"],
        path: "Sources/KauppaOrders/Repository"
    ),
    .target(
        name: "KauppaProductsRepository",
        dependencies: ["KauppaProductsModel", "KauppaCore"],
        path: "Sources/KauppaProducts/Repository"
    )
]

let serviceTargets: [Target] = [
    .target(
        name: "KauppaAccountsService",
        dependencies: ["KauppaAccountsRepository", "KauppaAccountsModel", "KauppaCore"],
        path: "Sources/KauppaAccounts/Service"
    ),
    .target(
        name: "KauppaTaxService",
        dependencies: ["KauppaCore"],
        path: "Sources/KauppaTax/Service"
    )
]

let daemonTargets: [Target] = [
    .target(
        name: "KauppaAccounts",
        dependencies: ["KauppaAccountsService", "KauppaAccountsRepository", "KauppaAccountsModel", "KauppaCore"],
        exclude: ["Service", "Repository", "Model"]
    ),
    .target(
        name: "KauppaOrders",
        dependencies: ["KauppaOrdersRepository", "KauppaOrdersModel", "KauppaCore"],
        exclude: ["Service", "Repository", "Model"]
    ),
    .target(
        name: "KauppaProducts",
        dependencies: ["KauppaProductsRepository", "KauppaProductsModel", "KauppaCore"],
        exclude: ["Service", "Repository", "Model"]
    ),
    .target(
        name: "KauppaTax",
        dependencies: ["KauppaCore"],
        exclude: ["Service", "Repository", "Model"]
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
        dependencies: ["KauppaTaxService", "KauppaCore"])
]

var targets: [Target] = [
    .target(
        name: "KauppaCore",
        dependencies: []
    )
]

targets.append(contentsOf: modelTargets)
targets.append(contentsOf: repositoryTargets)
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
