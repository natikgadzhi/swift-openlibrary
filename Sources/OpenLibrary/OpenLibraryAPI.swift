//
//  OpenLibraryAPI.swift
//
//  Created by Natik Gadzhi on 12/20/24.
//

import Foundation

/// An OpenLibrary API client.
///
public struct OpenLibraryAPI: Sendable {

    public struct Configuration: @unchecked Sendable {
        public let baseURL: URL
        public let session: URLSession
        public let userAgent: String?
        public let contactEmail: String?
        public let additionalHeaders: [String: String]

        public init(
            baseURL: URL = URL(string: "https://openlibrary.org")!,
            session: URLSession = .shared,
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

    public enum APIError: Error, LocalizedError, Sendable {
        case invalidURL(path: String)
        case invalidResponse
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

    /// Make a new instance of OpenLibrary API client that can fetch data from the Open Library API.
    ///
    /// - Parameters:
    ///  - configuration: A configurable transport and identification setup for the client.
    ///  - logger: A logger to use for logging messages. You can provide an instance of ``OSLog.Logger`` or something compatible.
    ///
    public init(
        configuration: Configuration = .init(),
        logger: OpenLibraryLoggerProtocol? = nil
    ) {
        self.configuration = configuration
        self.logger = logger
    }

    /// Make a new instance of OpenLibrary API client with default transport configuration.
    ///
    /// - Parameter logger: A logger to use for logging messages.
    ///
    public init(logger: OpenLibraryLoggerProtocol? = nil) {
        self.init(configuration: .init(), logger: logger)
    }

    /// A list of supported Open Library API endpoints
    ///
    enum Endpoints {

        /// Search for books (works) providing a query and an optional language code.
        /// If the language code is not provided, the language filter is omitted.
        ///
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

        /// Fetches the list of Editions by provided work key.
        /// Expects a work key in the format of `OL20057658W` without the `/works/` prefix.
        ///
        static func editions(workKey: String) -> RequestDescriptor {
            RequestDescriptor(
                path: "/works/\(workKey)/editions.json",
                queryItems: []
            )
        }
    }

    /// Search OpenLibrary API for books matching this query.
    /// https://openlibrary.org/dev/docs/api/search
    ///
    public func searchBooks(query: String) async throws -> [OpenLibrarySearchResult] {
        try await searchBooks(query: query, language: Self.defaultSearchLanguage())
    }

    public func searchBooks(
        query: String,
        language: String?
    ) async throws -> [OpenLibrarySearchResult] {
        let response: OpenLibrarySearchResponse = try await fetch(
            OpenLibrarySearchResponse.self,
            from: Endpoints.search(query: query, language: language)
        )

        logger?.info("Returning \(response.docs.count) books for query: \(query)")
        return response.docs
    }

    /// Fetches all editions for a particular work key, without pagination
    ///
    public func getWorkEditions(workKey: String) async throws -> [OpenLibraryEdition] {
        logger?.info("Fetching editions for work key: \(workKey)")

        let response: OpenLibraryEditionsResponse = try await fetch(
            OpenLibraryEditionsResponse.self,
            from: Endpoints.editions(workKey: workKey)
        )

        logger?.info("Returning \(response.entries.count) editions for work key: \(workKey)")
        return response.entries
    }

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
