// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenLibrary",
    products: [
        .library(
            name: "OpenLibrary",
            targets: ["OpenLibrary"]
        )
    ],
    targets: [
        .target(
            name: "OpenLibrary",
            swiftSettings: [
                .enableExperimentalFeature("BareSlashRegexLiterals")
            ]
        ),
        .testTarget(
            name: "OpenLibraryTests",
            dependencies: ["OpenLibrary"],
            swiftSettings: [
                .enableExperimentalFeature("BareSlashRegexLiterals")
            ]
        ),
    ]
)
