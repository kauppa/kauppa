// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Kauppa",
    products: [
        .executable(
            name: "KauppaOrders",
            targets: ["KauppaOrders", "KauppaCore"]
        ),
        .executable(
            name: "KauppaProducts",
            targets: ["KauppaProducts", "KauppaCore"]
        ),
        .executable(
            name: "KauppaTax",
            targets: ["KauppaTax", "KauppaCore"]
        )
    ],

    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "KauppaClient",
            dependencies: []),
        .target(
            name: "KauppaServer",
            dependencies: []),
        .target(
            name: "KauppaCore",
            dependencies: []),
        .target(
            name: "KauppaOrders",
            dependencies: ["KauppaCore", "Kitura"]),
        .target(
            name: "KauppaProducts",
            dependencies: ["KauppaCore", "Kitura"]),
        .target(
            name: "KauppaTax",
            dependencies: ["KauppaCore", "Kitura"]),
        .testTarget(
            name: "KauppaOrdersTests",
            dependencies: ["KauppaOrders", "KauppaCore", "Kitura"]),
        .testTarget(
            name: "KauppaProductsTests",
            dependencies: ["KauppaProducts", "KauppaCore", "Kitura"]),
        .testTarget(
            name: "KauppaTaxTests",
            dependencies: ["KauppaTax", "KauppaCore", "Kitura"])
    ]
)
