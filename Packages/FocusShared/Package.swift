// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "FocusShared",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: "FocusDomain", targets: ["FocusDomain"]),
        .library(name: "FocusData", targets: ["FocusData"])
    ],
    dependencies: [
        .package(path: "../FocusNetworking")
    ],
    targets: [
        .target(
            name: "FocusDomain"
        ),
        .target(
            name: "FocusData",
            dependencies: [
                "FocusDomain",
                .product(name: "FocusNetworking", package: "FocusNetworking")
            ]
        ),
        .testTarget(
            name: "FocusDomainTests",
            dependencies: ["FocusDomain"]
        ),
        .testTarget(
            name: "FocusDataTests",
            dependencies: ["FocusData", "FocusDomain"]
        )
    ]
)
