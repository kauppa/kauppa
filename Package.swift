// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Kauppa",
    dependencies: [
    ],
    targets: [
        .target(
            name: "KauppaClient",
            dependencies: []),
        .target(
            name: "KauppaServer",
            dependencies: []),
        .testTarget(
            name: "KauppaTests",
            dependencies: ["KauppaClient", "KauppaServer"])
    ]
)
