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
        // Note: ARCLogger and ARCNetworking are assumed to be local packages
        // If they don't exist, we'll create mock implementations
        // Uncomment these when the packages are available:
        // .package(path: "../ARCLogger"),
        // .package(path: "../ARCNetworking")
    ],
    targets: [
        .target(
            name: "ARCMaps",
            dependencies: [
                // Uncomment when packages are available:
                // .product(name: "ARCLogger", package: "ARCLogger"),
                // .product(name: "ARCNetworking", package: "ARCNetworking")
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
