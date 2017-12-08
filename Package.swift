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

let storeTargets: [Target] = [
    .target(
        name: "KauppaAccountsStore",
        dependencies: ["KauppaCore", "KauppaAccountsModel"],
        path: "Sources/KauppaAccounts/Store"
    ),
    .target(
        name: "KauppaOrdersStore",
        dependencies: ["KauppaCore", "KauppaOrdersModel"],
        path: "Sources/KauppaOrders/Store"
    ),
    .target(
        name: "KauppaProductsStore",
        dependencies: ["KauppaCore", "KauppaProductsModel"],
        path: "Sources/KauppaProducts/Store"
    )
]

let repositoryTargets: [Target] = [
    .target(
        name: "KauppaAccountsRepository",
        dependencies: ["KauppaAccountsStore", "KauppaAccountsModel", "KauppaCore"],
        path: "Sources/KauppaAccounts/Repository"
    ),
    .target(
        name: "KauppaOrdersRepository",
        dependencies: ["KauppaOrdersModel", "KauppaOrdersStore", "KauppaCore"],
        path: "Sources/KauppaOrders/Repository"
    ),
    .target(
        name: "KauppaProductsRepository",
        dependencies: ["KauppaProductsModel", "KauppaProductsStore", "KauppaCore"],
        path: "Sources/KauppaProducts/Repository"
    )
]

let serviceTargets: [Target] = [
    .target(
        name: "KauppaAccountsService",
        dependencies: ["KauppaAccountsRepository", "KauppaAccountsModel", "KauppaCore", "KauppaAccountsClient"],
        path: "Sources/KauppaAccounts/Service"
    ),
    .target(
        name: "KauppaOrdersService",
        dependencies: ["KauppaCore", "KauppaOrdersRepository", "KauppaOrdersModel", "KauppaProductsClient"],
        path: "Sources/KauppaOrders/Service"
    ),
    .target(
        name: "KauppaProductsService",
        dependencies: ["KauppaCore", "KauppaProductsClient", "KauppaProductsRepository", "KauppaProductsModel"],
        path: "Sources/KauppaProducts/Service"
    ),
    .target(
        name: "KauppaTaxService",
        dependencies: ["KauppaCore"],
        path: "Sources/KauppaTax/Service"
    )
]

let clientTargets: [Target] = [
    .target(
        name: "KauppaAccountsClient",
        dependencies: ["KauppaAccountsModel"],
        path: "Sources/KauppaAccounts/Client"
    ),
    .target(
        name: "KauppaOrdersClient",
        dependencies: ["KauppaOrdersModel"],
        path: "Sources/KauppaOrders/Client"
    ),
    .target(
        name: "KauppaProductsClient",
        dependencies: ["KauppaProductsModel"],
        path: "Sources/KauppaProducts/Client"
    )
]

let daemonTargets: [Target] = [
    .target(
        name: "KauppaAccounts",
        dependencies: [
            "KauppaAccountsClient",
            "KauppaAccountsService",
            "KauppaAccountsRepository",
            "KauppaAccountsModel",
            "KauppaCore"
        ],
        exclude: ["Client", "Service", "Repository", "Model", "Store"]
    ),
    .target(
        name: "KauppaOrders",
        dependencies: [
            "KauppaOrdersClient",
            "KauppaOrdersService",
            "KauppaOrdersRepository",
            "KauppaOrdersModel",
            "KauppaCore"
        ],
        exclude: ["Client", "Service", "Repository", "Model", "Store"]
    ),
    .target(
        name: "KauppaProducts",
        dependencies: [
            "KauppaProductsClient",
            "KauppaProductsService",
            "KauppaProductsRepository",
            "KauppaProductsModel",
            "KauppaCore"
        ],
        exclude: ["Client", "Service", "Repository", "Model", "Store"]
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
        dependencies: ["KauppaAccountsService", "KauppaAccountsModel", "KauppaCore"]
    ),
    .testTarget(
        name: "KauppaCoreTests",
        dependencies: ["KauppaCore"]
    ),
    .testTarget(
        name: "KauppaOrdersTests",
        dependencies: [
            "KauppaCore",
            "KauppaProductsModel",
            "KauppaOrdersClient",
            "KauppaOrdersModel",
            "KauppaOrdersStore",
            "KauppaOrdersRepository",
            "KauppaOrdersService",
            "KauppaOrdersStore",
        ]
    ),
    .testTarget(
        name: "KauppaProductsTests",
        dependencies: [
            "KauppaProductsModel",
            "KauppaProductsRepository",
            "KauppaProductsService",
            "KauppaCore"
        ]
    ),
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
targets.append(contentsOf: storeTargets)
targets.append(contentsOf: serviceTargets)
targets.append(contentsOf: clientTargets)
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
