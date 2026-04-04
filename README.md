# OpenLibrary

A Swift library for interacting with the [OpenLibrary](https://openlibrary.org) API. This package provides a clean, type-safe interface to search books, fetch book details, and work with selected OpenLibrary endpoints.

## Features

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

// Build cover and author image URLs directly.
let coverURL = OpenLibraryCovers.bookURL(for: .coverID(9238695), size: .large)
let authorPhotoURL = OpenLibraryCovers.authorPhotoURL(for: .authorKey("OL23919A"), size: .medium)

// Fetch a single edition by edition key
let edition = try await client.getEdition(editionKey: "OL20057658M")

// Fetch a subject page with expanded metadata.
let subject = try await client.getSubject(
    subjectSlug: "love",
    options: .init(details: true, limit: 10)
)

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

## Supported Methods

The package currently wraps these Open Library endpoints:

- `search(query:language:)` and `searchBooks(query:language:)` - [Search API](https://openlibrary.org/dev/docs/api/search)
- `getEdition(editionKey:)` - [Books API](https://openlibrary.org/dev/docs/api/books)
- `getWork(workKey:)` - [Works API](https://openlibrary.org/dev/docs/api/books)
- `getWorkEditions(workKey:)` - [Works API](https://openlibrary.org/dev/docs/api/books)
- `getWorkRatings(workKey:)` - [Work ratings endpoint](https://openlibrary.org/works/OL45804W/ratings.json)
- `getWorkBookshelves(workKey:)` - [Work bookshelves endpoint](https://openlibrary.org/works/OL45804W/bookshelves.json)
- `getSubject(subjectSlug:options:)` - [Subjects API](https://openlibrary.org/dev/docs/api/subjects)
- `OpenLibraryCovers.bookURL(...)` and `OpenLibraryCovers.authorPhotoURL(...)` - [Covers API](https://openlibrary.org/dev/docs/api/covers)

The command line example target also exposes these package capabilities from the terminal.

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
