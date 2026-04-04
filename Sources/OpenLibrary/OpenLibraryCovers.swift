//
//  OpenLibraryCovers.swift
//
//  Created by Natik Gadzhi on 4/4/26.
//

import Foundation

/// Utilities for building Open Library image URLs.
///
/// This namespace does not perform network requests. It only builds stable,
/// deterministic URLs from identifiers so callers can use the same logic across
/// works, editions, authors, and external identifiers.
public enum OpenLibraryCovers {
    /// Supported image sizes for Open Library cover and author-photo assets.
    public enum Size: String, CaseIterable, Sendable {
        /// Small image variant (`-S`).
        case small = "S"

        /// Medium image variant (`-M`).
        case medium = "M"

        /// Large image variant (`-L`).
        case large = "L"
    }

    /// Supported keys for book cover lookup.
    public enum BookKey: Sendable {
        /// An Open Library cover identifier.
        case coverID(Int)

        /// An Open Library edition key such as `OL7353617M`.
        case editionKey(String)

        /// A normalized or hyphenated ISBN value.
        case isbn(String)

        /// An OCLC identifier.
        case oclc(String)

        /// An LCCN identifier.
        case lccn(String)
    }

    /// Supported keys for author photo lookup.
    public enum AuthorKey: Sendable {
        /// An Open Library author photo identifier.
        case photoID(Int)

        /// An Open Library author key such as `OL23919A`.
        case authorKey(String)
    }

    /// Builds a cover image URL for a book-related identifier.
    ///
    /// - Parameters:
    ///   - key: The identifier used by the Covers API.
    ///   - size: The desired image size.
    /// - Returns: A URL that can be fetched directly, or `nil` if URL creation fails.
    public static func bookURL(for key: BookKey, size: Size = .large) -> URL? {
        let path: String
        switch key {
        case .coverID(let id):
            path = "/b/id/\(id)-\(size.rawValue).jpg"
        case .editionKey(let key):
            path = "/b/olid/\(key)-\(size.rawValue).jpg"
        case .isbn(let isbn):
            path = "/b/isbn/\(normalizedIdentifier(isbn))-\(size.rawValue).jpg"
        case .oclc(let oclc):
            path = "/b/oclc/\(normalizedIdentifier(oclc))-\(size.rawValue).jpg"
        case .lccn(let lccn):
            path = "/b/lccn/\(normalizedIdentifier(lccn))-\(size.rawValue).jpg"
        }

        return URL(string: "https://covers.openlibrary.org\(path)")
    }

    /// Builds an author photo URL.
    ///
    /// - Parameters:
    ///   - key: The author identifier used by the Covers API.
    ///   - size: The desired image size.
    /// - Returns: A URL that can be fetched directly, or `nil` if URL creation fails.
    public static func authorPhotoURL(for key: AuthorKey, size: Size = .large) -> URL? {
        let path: String
        switch key {
        case .photoID(let id):
            path = "/a/id/\(id)-\(size.rawValue).jpg"
        case .authorKey(let key):
            path = "/a/olid/\(key)-\(size.rawValue).jpg"
        }

        return URL(string: "https://covers.openlibrary.org\(path)")
    }

    private static func normalizedIdentifier(_ rawValue: String) -> String {
        rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
