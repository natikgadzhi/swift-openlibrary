# OpenLibrary

A Swift cross-platform library for interacting with the [OpenLibrary](https://openlibrary.org) API. This package provides a clean, type-safe interface to search books, fetch book details, and interact with other OpenLibrary endpoints.

## Features

- Cross-platform support (iOS, macOS, Linux)
- Type-safe API client
- Async/await based API
- Configurable logging
- Zero external dependencies

## Installation

Add this package to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/natikgadzhi/swift-openlibrary.git", branch: "main")
]
```

## Usage

```swift
import OpenLibrary

// Initialize the client
let client = OpenLibraryAPI()

// Search for books
let results = try await client.search(query: "Foundation Asimov")

// Fetch book details
let book = try await client.fetchBook(id: "OL1234W")
```

## License

MIT License. See LICENSE file for details. 