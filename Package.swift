// swift-tools-version: 5.9

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
            name: "OpenLibrary"
        ),
        .testTarget(
            name: "OpenLibraryTests",
            dependencies: ["OpenLibrary"]
        ),
    ]
)
