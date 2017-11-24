// swift-tools-version:4.0

import PackageDescription

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
    targets: [
        .target(
            name: "KauppaCore",
            dependencies: []),
        .target(
            name: "KauppaAccounts",
            dependencies: ["KauppaAccountsService", "KauppaAccountsModel", "KauppaCore"],
            exclude: ["Service", "Model"]
        ),
        .target(
            name: "KauppaAccountsService",
            dependencies: ["KauppaAccountsModel", "KauppaCore"],
            path: "Sources/KauppaAccounts/Service"
        ),
        .target(
            name: "KauppaAccountsModel",
            dependencies: ["KauppaCore"],
            path: "Sources/KauppaAccounts/Model"
        ),
        .target(
            name: "KauppaOrders",
            dependencies: ["KauppaOrdersModel", "KauppaCore"],
            exclude: ["Model"]
        ),
        .target(
            name: "KauppaOrdersModel",
            dependencies: ["KauppaCore", "KauppaProductsModel"],
            path: "Sources/KauppaOrders/Model"
        ),
        .target(
            name: "KauppaProducts",
            dependencies: ["KauppaProductsModel", "KauppaCore"],
            exclude: ["Model"]),
        .target(
            name: "KauppaProductsModel",
            dependencies: ["KauppaCore"],
            path: "Sources/KauppaProducts/Model"),
        .target(
            name: "KauppaTax",
            dependencies: ["KauppaCore"]),
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
)
