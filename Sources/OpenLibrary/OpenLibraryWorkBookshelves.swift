//
//  OpenLibraryWorkBookshelves.swift
//
//  Created by Natik Gadzhi on 4/4/26.
//

import Foundation

/// A typed representation of `/works/{id}/bookshelves.json`.
///
/// Open Library currently returns a small count object describing how many users
/// have placed a work on each public bookshelf.
public struct OpenLibraryWorkBookshelvesResponse: Decodable, Sendable {
    /// The public bookshelf counts.
    public let counts: Counts

    /// The total number of shelf placements represented by this response.
    public var totalCount: Int {
        counts.wantToRead + counts.currentlyReading + counts.alreadyRead
    }

    /// Creates a bookshelf response from JSON returned by Open Library.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        counts = try container.decode(Counts.self, forKey: .counts)
    }

    private enum CodingKeys: String, CodingKey {
        case counts
    }
}

extension OpenLibraryWorkBookshelvesResponse {
    /// The count of public shelf placements by shelf type.
    public struct Counts: Decodable, Sendable {
        /// The count of `want-to-read` placements.
        public let wantToRead: Int

        /// The count of `currently-reading` placements.
        public let currentlyReading: Int

        /// The count of `already-read` placements.
        public let alreadyRead: Int

        private enum CodingKeys: String, CodingKey {
            case wantToRead = "want_to_read"
            case currentlyReading = "currently_reading"
            case alreadyRead = "already_read"
        }
    }
}
