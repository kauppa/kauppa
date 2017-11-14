// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Kauppa",
    dependencies: [
        // .package(url: "git@gitlab.com:Omnijar/Naamio/nokka.git", from: "0.1.0"),
        .package(url: "../nokka", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "KauppaClient",
            dependencies: ["Nokka"]),
        .target(
            name: "KauppaServer",
            dependencies: ["Nokka"]),
        .testTarget(
            name: "KauppaTests",
            dependencies: ["KauppaClient", "KauppaServer", "Nokka"])
    ]
)
