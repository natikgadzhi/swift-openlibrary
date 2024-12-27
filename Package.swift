// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenLibrary",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v8),
        .macCatalyst(.v17),
        .tvOS(.v16)
    ],
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
