//
//  OpenLibraryAPI.swift
//
//  Created by Natik Gadzhi on 12/20/24.
//

import Foundation

/// A small async transport abstraction used by ``OpenLibraryAPI``.
///
/// `OpenLibraryAPI` is fully `Sendable`, so its networking dependency also needs
/// to be sendable under Swift 6's strict concurrency model. This protocol keeps
/// that dependency narrow and testable while still allowing `URLSession` to be
/// the default concrete implementation.
public protocol OpenLibraryHTTPSession: Sendable {
    /// Loads data for a request.
    ///
    /// - Parameter request: The request to execute.
    /// - Returns: The response body and its corresponding URL response.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: OpenLibraryHTTPSession {
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}

/// An OpenLibrary API client.
///
/// This type is `Sendable`, so you can safely move it across tasks and actor
/// boundaries. It does not own mutable shared state. Request execution happens
/// through an injected async transport (`OpenLibraryHTTPSession`) and each call
/// builds its own immutable `URLRequest`.
public struct OpenLibraryAPI: Sendable {

    /// Configuration for an ``OpenLibraryAPI`` instance.
    ///
    /// The configuration is immutable and `Sendable`, which means you can create
    /// a client once and safely reuse it from concurrent tasks.
    public struct Configuration: Sendable {
        /// The base URL used to build endpoint URLs.
        public let baseURL: URL

        /// The async transport used to execute requests.
        ///
        /// In production this is normally `URLSession.shared`. In tests you can
        /// inject a lightweight stub that conforms to ``OpenLibraryHTTPSession``.
        public let session: any OpenLibraryHTTPSession

        /// A `User-Agent` header identifying the calling application.
        public let userAgent: String?

        /// A contact email used for the `From` header.
        public let contactEmail: String?

        /// Additional headers applied to every request.
        public let additionalHeaders: [String: String]

        /// Creates a new client configuration.
        ///
        /// - Parameters:
        ///   - baseURL: The base Open Library host. Defaults to `https://openlibrary.org`.
        ///   - session: The sendable async transport used to perform requests.
        ///   - userAgent: A `User-Agent` header value for API identification.
        ///   - contactEmail: A `From` header value for API identification.
        ///   - additionalHeaders: Extra headers to include on all requests.
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

    /// Errors returned by ``OpenLibraryAPI``.
    public enum APIError: Error, LocalizedError, Sendable {
        /// URL construction failed for the supplied endpoint path.
        case invalidURL(path: String)

        /// The server returned a non-HTTP response.
        case invalidResponse

        /// The server returned an unsuccessful HTTP status code.
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
    ///   - logger: A logger to use for diagnostic messages.
    public init(
        configuration: Configuration = .init(),
        logger: OpenLibraryLoggerProtocol? = nil
    ) {
        self.configuration = configuration
        self.logger = logger
    }

    /// Creates a new client with the default configuration.
    ///
    /// - Parameter logger: A logger to use for diagnostic messages.
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
    ///   - language: An optional ISO 639-2 language code applied as a search filter.
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
    /// This remains as a convenience wrapper around ``search(query:language:)``.
    ///
    /// - Parameter query: The search query.
    /// - Returns: The `docs` array from the paginated search response.
    public func searchBooks(query: String) async throws -> [OpenLibrarySearchResult] {
        let response = try await search(query: query)
        return response.docs
    }

    /// Searches Open Library and returns only the search documents.
    ///
    /// - Parameters:
    ///   - query: The search query.
    ///   - language: An optional ISO 639-2 language code applied as a search filter.
    /// - Returns: The `docs` array from the paginated search response.
    public func searchBooks(
        query: String,
        language: String?
    ) async throws -> [OpenLibrarySearchResult] {
        let response = try await search(query: query, language: language)
        return response.docs
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

    /// Fetches all editions for a work, without automatically traversing pagination.
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

    private static func defaultSearchLanguage() -> String? {
        Locale.current.language.languageCode?.identifier(.alpha3)
    }

    private static func makeDecoder() -> JSONDecoder {
        JSONDecoder()
    }
}
