// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "FocusNetworking",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: "FocusNetworking", targets: ["FocusNetworking"])
    ],
    targets: [
        .target(
            name: "FocusNetworking"
        ),
        .testTarget(
            name: "FocusNetworkingTests",
            dependencies: ["FocusNetworking"]
        )
    ]
)
