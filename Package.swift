// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARCMaps",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ARCMaps",
            targets: ["ARCMaps"]
        ),
        .library(
            name: "ARCMapsTestHelpers",
            targets: ["ARCMapsTestHelpers"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/arclabs-studio/ARCLogger", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "ARCMaps",
            dependencies: [
                .product(name: "ARCLogger", package: "ARCLogger")
            ],
            path: "Sources/ARCMaps",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "ARCMapsTestHelpers",
            dependencies: ["ARCMaps"],
            path: "Sources/ARCMapsTestHelpers",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ARCMapsTests",
            dependencies: [
                "ARCMaps",
                "ARCMapsTestHelpers"
            ],
            path: "Tests/ARCMapsTests",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
