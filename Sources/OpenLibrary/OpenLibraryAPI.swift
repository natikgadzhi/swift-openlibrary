//
//  OpenLibraryAPI.swift
//
//  Created by Natik Gadzhi on 12/20/24.
//

import Foundation

/// An async transport abstraction for Open Library requests.
///
/// ``OpenLibraryAPI`` is `Sendable`, so its request transport must also be
/// safe to move across concurrency domains. This protocol keeps the dependency
/// narrow while allowing `URLSession` to remain the default production
/// transport.
public protocol OpenLibraryHTTPSession: Sendable {
    /// Loads data for a URL request.
    ///
    /// - Parameter request: The request to execute.
    /// - Returns: The raw response body and the corresponding URL response.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: OpenLibraryHTTPSession {
    /// Loads data for a URL request using `URLSession`.
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}

/// An Open Library API client.
///
/// The client is intentionally small and immutable. Each call builds its own
/// request and awaits the injected async transport, which keeps the public API
/// predictable under Swift 6's strict concurrency checks.
public struct OpenLibraryAPI: Sendable {

    /// Configuration for an ``OpenLibraryAPI`` instance.
    public struct Configuration: Sendable {
        /// The base URL used to construct endpoint URLs.
        public let baseURL: URL

        /// The sendable async transport used to execute requests.
        public let session: any OpenLibraryHTTPSession

        /// Optional `User-Agent` header for API identification.
        public let userAgent: String?

        /// Optional `From` header for API identification.
        public let contactEmail: String?

        /// Additional headers applied to every request.
        public let additionalHeaders: [String: String]

        /// Creates a new client configuration.
        ///
        /// - Parameters:
        ///   - baseURL: The Open Library host. Defaults to `https://openlibrary.org`.
        ///   - session: The sendable async transport used to perform requests.
        ///   - userAgent: Optional `User-Agent` value to identify the app.
        ///   - contactEmail: Optional `From` value to identify the app.
        ///   - additionalHeaders: Extra headers applied to every request.
        public init(
            baseURL: URL = URL(string: "https://openlibrary.org")!,
            session: any OpenLibraryHTTPSession = URLSession.shared,
            userAgent: String? = nil,
            contactEmail: String? = nil,
            additionalHeaders: [String: String] = [:]
        ) {
            self.baseURL = baseURL
            self.session = session
            self.userAgent = userAgent
            self.contactEmail = contactEmail
            self.additionalHeaders = additionalHeaders
        }
    }

    /// Errors emitted by ``OpenLibraryAPI``.
    public enum APIError: Error, LocalizedError, Sendable {
        /// URL construction failed for the supplied path.
        case invalidURL(path: String)

        /// The server returned a non-HTTP response.
        case invalidResponse

        /// The server returned a non-2xx response.
        case unexpectedStatusCode(Int, body: String?)

        public var errorDescription: String? {
            switch self {
            case .invalidURL(let path):
                "Failed to construct a valid Open Library URL for path: \(path)"
            case .invalidResponse:
                "Open Library returned an invalid response."
            case .unexpectedStatusCode(let statusCode, let body):
                if let body, !body.isEmpty {
                    "Open Library returned HTTP \(statusCode): \(body)"
                } else {
                    "Open Library returned HTTP \(statusCode)."
                }
            }
        }
    }

    struct RequestDescriptor: Sendable {
        let path: String
        let queryItems: [URLQueryItem]
    }

    let configuration: Configuration
    let logger: OpenLibraryLoggerProtocol?

    /// Creates a new Open Library client.
    ///
    /// - Parameters:
    ///   - configuration: The immutable transport and header configuration.
    ///   - logger: Optional logger for request/response diagnostics.
    public init(
        configuration: Configuration = .init(),
        logger: OpenLibraryLoggerProtocol? = nil
    ) {
        self.configuration = configuration
        self.logger = logger
    }

    /// Creates a client with the default configuration.
    ///
    /// - Parameter logger: Optional logger for request/response diagnostics.
    public init(logger: OpenLibraryLoggerProtocol? = nil) {
        self.init(configuration: .init(), logger: logger)
    }

    enum Endpoints {
        static func search(query: String, language: String?) -> RequestDescriptor {
            let effectiveQuery: String
            if let language, !language.isEmpty {
                effectiveQuery = "\(query) language:\(language)"
            } else {
                effectiveQuery = query
            }

            return RequestDescriptor(
                path: "/search.json",
                queryItems: [
                    URLQueryItem(name: "q", value: effectiveQuery),
                    URLQueryItem(name: "fields", value: "*,editions"),
                ]
            )
        }

        static func edition(editionKey: String) -> RequestDescriptor {
            RequestDescriptor(
                path: "/books/\(normalizedEditionKey(editionKey)).json",
                queryItems: []
            )
        }

        static func work(workKey: String) -> RequestDescriptor {
            RequestDescriptor(
                path: "/works/\(workKey).json",
                queryItems: []
            )
        }

        static func editions(workKey: String) -> RequestDescriptor {
            RequestDescriptor(
                path: "/works/\(workKey)/editions.json",
                queryItems: []
            )
        }

        static func ratings(workKey: String) -> RequestDescriptor {
            RequestDescriptor(
                path: "/works/\(workKey)/ratings.json",
                queryItems: []
            )
        }

        static func bookshelves(workKey: String) -> RequestDescriptor {
            RequestDescriptor(
                path: "/works/\(workKey)/bookshelves.json",
                queryItems: []
            )
        }

        private static func normalizedEditionKey(_ key: String) -> String {
            if key.starts(with: "/books/") {
                String(key.dropFirst(7))
            } else {
                key
            }
        }
    }

    /// Searches Open Library and returns the full paginated response envelope.
    ///
    /// - Parameter query: The search query.
    /// - Returns: A paginated collection of search results.
    public func search(query: String) async throws -> OpenLibrarySearchResults {
        try await search(query: query, language: Self.defaultSearchLanguage())
    }

    /// Searches Open Library and returns the full paginated response envelope.
    ///
    /// - Parameters:
    ///   - query: The search query.
    ///   - language: An optional ISO 639-2 language code used as a search filter.
    /// - Returns: A paginated collection of search results.
    public func search(
        query: String,
        language: String?
    ) async throws -> OpenLibrarySearchResults {
        let response: OpenLibrarySearchResults = try await fetch(
            OpenLibrarySearchResults.self,
            from: Endpoints.search(query: query, language: language)
        )

        logger?.info("Returning \(response.docs.count) search results for query: \(query)")
        return response
    }

    /// Searches Open Library and returns only the search documents.
    ///
    /// - Parameter query: The search query.
    /// - Returns: The `docs` array from the paginated search response.
    public func searchBooks(query: String) async throws -> [OpenLibrarySearchResult] {
        try await search(query: query).docs
    }

    /// Searches Open Library and returns only the search documents.
    ///
    /// - Parameters:
    ///   - query: The search query.
    ///   - language: An optional ISO 639-2 language code used as a search filter.
    /// - Returns: The `docs` array from the paginated search response.
    public func searchBooks(
        query: String,
        language: String?
    ) async throws -> [OpenLibrarySearchResult] {
        try await search(query: query, language: language).docs
    }

    /// Fetches a single edition.
    ///
    /// - Parameter editionKey: An edition key such as `OL20057658M`, with or without the `/books/` prefix.
    /// - Returns: The decoded edition record.
    public func getEdition(editionKey: String) async throws -> OpenLibraryEdition {
        logger?.info("Fetching edition for key: \(editionKey)")

        let response: OpenLibraryEdition = try await fetch(
            OpenLibraryEdition.self,
            from: Endpoints.edition(editionKey: editionKey)
        )

        logger?.info("Returning edition for key: \(editionKey)")
        return response
    }

    /// Fetches an individual work.
    ///
    /// - Parameter workKey: A work key such as `OL45804W`, without the `/works/` prefix.
    /// - Returns: The decoded work record.
    public func getWork(workKey: String) async throws -> OpenLibraryWork {
        logger?.info("Fetching work for key: \(workKey)")

        let response: OpenLibraryWork = try await fetch(
            OpenLibraryWork.self,
            from: Endpoints.work(workKey: workKey)
        )

        logger?.info("Returning work for key: \(workKey)")
        return response
    }

    /// Fetches all editions for a work, without automatic pagination traversal.
    ///
    /// - Parameter workKey: A work key such as `OL45804W`, without the `/works/` prefix.
    /// - Returns: The first page of editions for the work.
    public func getWorkEditions(workKey: String) async throws -> [OpenLibraryEdition] {
        logger?.info("Fetching editions for work key: \(workKey)")

        let response: OpenLibraryEditionsResponse = try await fetch(
            OpenLibraryEditionsResponse.self,
            from: Endpoints.editions(workKey: workKey)
        )

        logger?.info("Returning \(response.entries.count) editions for work key: \(workKey)")
        return response.entries
    }

    /// Fetches the rating summary and star histogram for a work.
    ///
    /// The returned model mirrors the `/works/{id}/ratings.json` payload and
    /// keeps the response fully typed for downstream code.
    ///
    /// - Parameter workKey: A work key such as `OL18020194W`, without the `/works/` prefix.
    /// - Returns: The decoded ratings summary for the work.
    public func getWorkRatings(workKey: String) async throws -> OpenLibraryWorkRatingsResponse {
        logger?.info("Fetching ratings for work key: \(workKey)")

        let response: OpenLibraryWorkRatingsResponse = try await fetch(
            OpenLibraryWorkRatingsResponse.self,
            from: Endpoints.ratings(workKey: workKey)
        )

        logger?.info("Returning ratings for work key: \(workKey)")
        return response
    }

    /// Fetches the public bookshelf counts for a work.
    ///
    /// The returned model mirrors the `/works/{id}/bookshelves.json` payload and
    /// provides typed access to the three bookshelf counters that Open Library exposes.
    ///
    /// - Parameter workKey: A work key such as `OL18020194W`, without the `/works/` prefix.
    /// - Returns: The decoded bookshelf summary for the work.
    public func getWorkBookshelves(
        workKey: String
    ) async throws -> OpenLibraryWorkBookshelvesResponse {
        logger?.info("Fetching bookshelves for work key: \(workKey)")

        let response: OpenLibraryWorkBookshelvesResponse = try await fetch(
            OpenLibraryWorkBookshelvesResponse.self,
            from: Endpoints.bookshelves(workKey: workKey)
        )

        logger?.info("Returning bookshelves for work key: \(workKey)")
        return response
    }

    /// Performs a request and decodes the JSON payload.
    ///
    /// The async boundary here is the network call. All request-building data is
    /// immutable before the `await`, so no synchronization is needed inside the
    /// client itself.
    private func fetch<Response: Decodable>(
        _ responseType: Response.Type,
        from endpoint: RequestDescriptor
    ) async throws -> Response {
        let url = try makeURL(for: endpoint)
        let request = makeRequest(url: url)

        let (data, response) = try await configuration.session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.unexpectedStatusCode(
                httpResponse.statusCode,
                body: String(data: data, encoding: .utf8)
            )
        }

        return try Self.makeDecoder().decode(responseType, from: data)
    }

    /// Builds a full URL from the configured base URL and endpoint descriptor.
    private func makeURL(for endpoint: RequestDescriptor) throws -> URL {
        guard var components = URLComponents(
            url: configuration.baseURL,
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL(path: endpoint.path)
        }

        let basePath = components.path.hasSuffix("/")
            ? String(components.path.dropLast())
            : components.path
        components.path = basePath + endpoint.path
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems

        guard let url = components.url else {
            throw APIError.invalidURL(path: endpoint.path)
        }

        return url
    }

    /// Builds a request with the configured identification headers.
    private func makeRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let userAgent = configuration.userAgent {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }

        if let contactEmail = configuration.contactEmail {
            request.setValue(contactEmail, forHTTPHeaderField: "From")
        }

        for (field, value) in configuration.additionalHeaders {
            request.setValue(value, forHTTPHeaderField: field)
        }

        return request
    }

    /// Derives a default ISO 639-2 language tag from the current locale.
    private static func defaultSearchLanguage() -> String? {
        Locale.current.language.languageCode?.identifier(.alpha3)
    }

    /// Creates the decoder used by all response types.
    private static func makeDecoder() -> JSONDecoder {
        JSONDecoder()
    }
}
