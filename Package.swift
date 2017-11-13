// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Kauppa",
    products: [
        .executable(
            name: "Kauppa",
            targets: ["Kauppa"]),
    ],
    dependencies: [
        //.package(url: "git@github.com:Naamio/nokka.git", from: "0.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Kauppa",
            dependencies: []),
        .testTarget(
            name: "KauppaTests",
            dependencies: ["Kauppa"]),
    ]
)
