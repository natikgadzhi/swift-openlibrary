// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "OpenLibrary",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .watchOS(.v8),
    .macCatalyst(.v17),
    .tvOS(.v16),
  ],
  products: [
    .library(
      name: "OpenLibrary",
      targets: ["OpenLibrary"]
    ),
    .executable(
      name: "openlibrary",
      targets: ["OpenLibraryCLI"]
    ),
  ],
  targets: [
    .target(
      name: "OpenLibrary"
    ),
    .executableTarget(
      name: "OpenLibraryCLI",
      dependencies: ["OpenLibrary"]
    ),
    .testTarget(
      name: "OpenLibraryTests",
      dependencies: ["OpenLibrary"],
      path: "Tests/OpenLibraryAPITests"
    ),
    .testTarget(
      name: "OpenLibraryCLITests",
      dependencies: ["OpenLibraryCLI"],
      path: "Tests/OpenLibraryCLITests"
    ),
  ],
  swiftLanguageModes: [.v6]
)
