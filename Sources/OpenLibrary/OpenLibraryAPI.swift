//
//  OpenLibraryAPI.swift
//
//  Created by Natik Gadzhi on 12/20/24.
//

import Foundation

/// An OpenLibrary API client.
///
public struct OpenLibraryAPI {

    let logger: OpenLibraryLoggerProtocol?

    /// Make a new instance of OpenLibrary API client that can fetch data from the Open Library API.
    ///
    /// - Parameters:
    ///  - logger: A logger to use for logging messages. You can provide an instance of ``OSLog.Logger`` or something compatible.
    ///
    public init(logger: OpenLibraryLoggerProtocol? = nil) {
        self.logger = logger
    }

    /// A list of supported Open Library API endpoints
    ///
    enum Endpoints {

        /// Search for books (works) providing a query and a language code.
        /// If the language code is not provided, `language:` filter in the search query will not be appended.
        ///
        public static func search(query: String, language: String?) -> URL {
            if let language = language {
                return URL(
                    string:
                        "https://openlibrary.org/search.json?q=\(query) language:\(language)&fields=*,editions"
                )!
            } else {
                return URL(
                    string: "https://openlibrary.org/search.json?q=\(query)&fields=*,editions")!
            }
        }

        /// Fetches the list of Editions by provided work key.
        /// Expects a work key in the format of `OL20057658W` without the `/works/` prefix.
        ///
        public static func editions(workKey: String) -> URL {
            return URL(string: "https://openlibrary.org/works/\(workKey)/editions.json")!
        }

    }

    /// Search OpenLibrary API for books matching this query.
    /// https://openlibrary.org/dev/docs/api/search
    ///
    public func searchBooks(query: String) async throws -> [OpenLibraryWork] {

        // Use the language that the user's system has
        let languageCode = Locale.current.language.languageCode?.identifier(.alpha3) ?? "eng"
        let url = Endpoints.search(query: query, language: languageCode)

        let session = URLSession(configuration: .ephemeral)
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)

        logger?.info("Returning \(response.docs.count) books for query: \(query)")
        return response.docs
    }

    /// Fetches all editions for a particular work key, without pagination
    ///
    public func getWorkEditions(workKey: String) async throws -> [OpenLibraryEdition] {
        logger?.info("Fetching editions for work key: \(workKey)")
        let url = Endpoints.editions(workKey: workKey)

        let session = URLSession(configuration: .ephemeral)
        let (data, _) = try await session.data(from: url)

        let response = try JSONDecoder().decode(OpenLibraryEditionsResponse.self, from: data)

        logger?.info("Returning \(response.entries.count) editions for work key: \(workKey)")
        return response.entries
    }

}
