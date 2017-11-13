// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Kauppa",
    products: [
        .executable(
            name: "Kauppa",
            targets: ["Kauppa"])
    ],
    dependencies: [
        //.package(url: "git@github.com:Naamio/nokka.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "Kauppa",
            dependencies: []),
        .testTarget(
            name: "KauppaTests",
            dependencies: ["Kauppa"])
    ]
)
