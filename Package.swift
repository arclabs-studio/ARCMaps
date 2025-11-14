// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARCMaps",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "ARCMaps",
            targets: ["ARCMaps"]
        ),
    ],
    targets: [
        .target(
            name: "ARCMaps",
            path: "Sources"
        ),
        .testTarget(
            name: "ARCMapsTests",
            dependencies: ["ARCMaps"],
            path: "Tests"
        )
    ]
)
