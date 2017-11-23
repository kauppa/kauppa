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
            dependencies: ["KauppaAccountsModel", "KauppaCore"],
            exclude: ["Model"]
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
            dependencies: [],
            path: "Sources/KauppaProducts/Model"),
        .target(
            name: "KauppaTax",
            dependencies: ["KauppaCore"]),
        .testTarget(
            name: "KauppaAccountsTests",
            dependencies: ["KauppaCore"]),
        .testTarget(
            name: "KauppaOrdersTests",
            dependencies: ["KauppaCore"]),
        .testTarget(
            name: "KauppaProductsTests",
            dependencies: ["KauppaCore"]),
        .testTarget(
            name: "KauppaTaxTests",
            dependencies: ["KauppaCore"])
    ]
)
