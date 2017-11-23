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
        .package(url: "https://github.com/IBM-Swift/Kitura", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "KauppaCore",
            dependencies: ["Kitura"]),
        .target(
            name: "KauppaAccounts",
            dependencies: ["KauppaCore"]),
        .target(
            name: "KauppaOrders",
            dependencies: ["KauppaCore"]),
        .target(
            name: "KauppaProducts",
            dependencies: ["KauppaCore"]),
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
