# OpenLibrary

A Swift library for interacting with the [OpenLibrary](https://openlibrary.org) API. This package provides a clean, type-safe interface to search books, fetch book details, and interact with other OpenLibrary endpoints.

## Features

- ~~Cross-platform support (iOS, macOS, Linux)~~ nope, not yet.
- Type-safe API client
- Async/await based API
- Configurable logging compatible with `OSLog.Logger`
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

// Search for books in the user's system language.
// Returns a paginated OpenLibrarySearchResults value.
let search = try await client.search(query: "Foundation Asimov")
let books = search.docs

// Fetch a single work by work key.
let work = try await client.getWork(workKey: "OL45804W")

// Fetch all editions for a specific work
// Returns an array of OpenLibraryEdition objects
let editions = try await client.getWorkEditions(workKey: "OL45883W")

// With logging enabled (on Apple platforms)
import OSLog
let logger = Logger(subsystem: "com.yourapp", category: "openlibrary")
let clientWithLogging = OpenLibraryAPI(
    configuration: .init(
        userAgent: "MyApp/1.0",
        contactEmail: "me@example.com"
    ),
    logger: logger
)
```

## CLI Example

The package also includes a small executable example target for quick inspection
from the terminal:

```bash
swift run openlibrary search "Pattern Recognition" --limit 3
swift run openlibrary editions OL45883W --limit 5
```

## Logging

The library supports logging through a simple protocol `OpenLibraryLoggerProtocol`. On Apple platforms, `OSLog.Logger` is supported out of the box. For other platforms, you can implement the protocol with your preferred logging solution.

## API etiquette

Open Library asks API clients to identify themselves and behave politely:

- Set a descriptive `User-Agent` for your app or service.
- Provide a contact email when practical.
- Cache responses where it makes sense for your application.
- Avoid bursty or high-frequency polling. The Open Library developer docs describe a lower default rate limit for anonymous traffic and a higher one for identified clients.

This package exposes those headers through `OpenLibraryAPI.Configuration`:

```swift
let api = OpenLibraryAPI(
    configuration: .init(
        userAgent: "MyReaderApp/1.2",
        contactEmail: "api-support@example.com"
    )
)
```

## License

MIT License. See [LICENSE](LICENSE) file for details. 
