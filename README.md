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

// Initialize the client, optionally with a logger
let client = OpenLibraryAPI()

// Search for books in the user's system language
// Returns an array of OpenLibraryWork objects
let books = try await client.searchBooks(query: "Foundation Asimov")

// Fetch all editions for a specific work
// Returns an array of OpenLibraryEdition objects
let editions = try await client.getWorkEditions(workKey: "OL45883W")

// With logging enabled (on Apple platforms)
import OSLog
let logger = Logger(subsystem: "com.yourapp", category: "openlibrary")
let clientWithLogging = OpenLibraryAPI(logger: logger)
```

## Logging

The library supports logging through a simple protocol `OpenLibraryLoggerProtocol`. On Apple platforms, `OSLog.Logger` is supported out of the box. For other platforms, you can implement the protocol with your preferred logging solution.

## License

MIT License. See [LICENSE](LICENSE) file for details. 