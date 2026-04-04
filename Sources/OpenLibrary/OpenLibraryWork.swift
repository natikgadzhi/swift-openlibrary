//
//  OpenLibraryWork.swift
//
//  Created by Natik Gadzhi on 12/23/24.
//

import Foundation

/// A complete Open Library work record fetched from `/works/{id}.json`.
public struct OpenLibraryWork: Codable, Identifiable, Hashable, Sendable {
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case subtitle
        case description
        case authors
        case covers
        case subjects
        case subjectPlaces = "subject_places"
        case subjectPeople = "subject_people"
        case subjectTimes = "subject_times"
        case firstPublishDate = "first_publish_date"
        case latestRevision = "latest_revision"
        case revision
        case created
        case lastModified = "last_modified"
    }

    /// The normalized work identifier without the `/works/` prefix.
    public var id: String { key }

    /// The normalized work key, for example `OL45804W`.
    public let key: String

    /// The work title.
    public let title: String

    /// An optional subtitle for the work.
    public let subtitle: String?

    /// A plain-text description when one is present.
    public let description: String?

    /// Author references attached to the work.
    public let authors: [AuthorRole]

    /// Cover image identifiers associated with the work.
    public let covers: [Int]?

    /// Topical subjects attached to the work.
    public let subjects: [String]?

    /// Geographic subject tags attached to the work.
    public let subjectPlaces: [String]?

    /// Person-based subject tags attached to the work.
    public let subjectPeople: [String]?

    /// Time-based subject tags attached to the work.
    public let subjectTimes: [String]?

    /// The first publish date string as returned by Open Library.
    public let firstPublishDate: String?

    /// The latest revision number on the work.
    public let latestRevision: Int?

    /// The current revision number on the work.
    public let revision: Int?

    /// The creation timestamp wrapper returned by Open Library.
    public let created: RecordTimestamp?

    /// The last-modified timestamp wrapper returned by Open Library.
    public let lastModified: RecordTimestamp?

    /// Cover image URLs derived from ``covers``.
    public var coverImageURLs: [URL] {
        (covers ?? []).compactMap { URL(string: "https://covers.openlibrary.org/b/id/\($0)-L.jpg") }
    }

    /// The first cover image URL if one exists.
    public var coverImageURL: URL? {
        guard let firstCoverID = covers?.first else { return nil }
        return OpenLibraryCovers.bookURL(for: .coverID(firstCoverID), size: .large)
    }

    /// The normalized author keys associated with this work.
    public var authorKeys: [String] {
        authors.map(\.author.key)
    }

    /// Creates a work from a decoder.
    ///
    /// Open Library returns several fields in multiple shapes, especially
    /// `description`, which may be a wrapped text object or a plain string.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        key = Self.normalizeWorkKey(try container.decode(String.self, forKey: .key))
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        authors = try container.decodeIfPresent([AuthorRole].self, forKey: .authors) ?? []
        covers = try container.decodeIfPresent([Int].self, forKey: .covers)
        subjects = try container.decodeIfPresent([String].self, forKey: .subjects)
        subjectPlaces = try container.decodeIfPresent([String].self, forKey: .subjectPlaces)
        subjectPeople = try container.decodeIfPresent([String].self, forKey: .subjectPeople)
        subjectTimes = try container.decodeIfPresent([String].self, forKey: .subjectTimes)
        firstPublishDate = try container.decodeIfPresent(String.self, forKey: .firstPublishDate)
        latestRevision = try container.decodeIfPresent(Int.self, forKey: .latestRevision)
        revision = try container.decodeIfPresent(Int.self, forKey: .revision)
        created = try container.decodeIfPresent(RecordTimestamp.self, forKey: .created)
        lastModified = try container.decodeIfPresent(RecordTimestamp.self, forKey: .lastModified)

        if let wrappedDescription = try? container.decodeIfPresent(TextValue.self, forKey: .description) {
            description = wrappedDescription.value
        } else {
            description = try container.decodeIfPresent(String.self, forKey: .description)
        }
    }

    static func normalizeWorkKey(_ key: String) -> String {
        if key.starts(with: "/works/") {
            String(key.dropFirst(7))
        } else {
            key
        }
    }
}
extension OpenLibraryWork {
    /// A wrapped text field used by Open Library for some string values.
    public struct TextValue: Codable, Hashable, Sendable {
        /// The record type key.
        public let type: String

        /// The plain string value.
        public let value: String
    }

    /// A timestamp wrapper used by Open Library for record metadata.
    public struct RecordTimestamp: Codable, Hashable, Sendable {
        /// The record type key.
        public let type: String

        /// The raw timestamp string returned by the API.
        public let value: String
    }

    /// A typed work author role.
    public struct AuthorRole: Codable, Hashable, Sendable {
        /// The linked author reference.
        public let author: Reference

        /// The role type wrapper returned by Open Library.
        public let type: Reference?
    }

    /// A simple key reference wrapper.
    public struct Reference: Codable, Hashable, Sendable {
        /// The normalized key value without its `/authors/` or `/type/` prefix.
        public let key: String

        /// Creates a normalized reference from a decoder.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let rawKey = try container.decode(String.self, forKey: .key)
            key = Self.normalize(rawKey)
        }

        enum CodingKeys: String, CodingKey {
            case key
        }

        static func normalize(_ rawKey: String) -> String {
            if rawKey.starts(with: "/authors/") {
                String(rawKey.dropFirst(9))
            } else if rawKey.starts(with: "/type/") {
                String(rawKey.dropFirst(6))
            } else {
                rawKey
            }
        }
    }
}
