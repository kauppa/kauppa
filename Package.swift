// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Kauppa",
    products: [
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
            dependencies: ["KauppaCore", "Kitura"]),
        .testTarget(
            name: "KauppaProductsTests",
            dependencies: ["KauppaCore", "Kitura"]),
        .testTarget(
            name: "KauppaTaxTests",
            dependencies: ["KauppaCore", "Kitura"])
    ]
)
