//
//  OpenLibrarySubject.swift
//
//  Created by Natik Gadzhi on 4/4/26.
//

import Foundation

/// A decoded Open Library subject record from `/subjects/{slug}.json`.
///
/// Subjects are useful browse pages. They include a main work list plus summary
/// metadata such as total work counts, optional ebook counts, and, when
/// requested, expanded contributor breakdowns.
public struct OpenLibrarySubject: Decodable, Identifiable, Hashable, Sendable {
  enum CodingKeys: String, CodingKey {
    case key
    case name
    case subjectType = "subject_type"
    case workCount = "work_count"
    case ebookCount = "ebook_count"
    case works
    case authors
    case publishers
    case subjects
    case people
    case places
    case times
    case publishingHistory = "publishing_history"
  }

  /// The normalized subject key without the `/subjects/` prefix.
  public var id: String { key }

  /// The normalized subject key.
  public let key: String

  /// The subject display name.
  public let name: String

  /// The subject type returned by Open Library.
  public let subjectType: String

  /// The total number of works attached to the subject.
  public let workCount: Int

  /// The number of ebook works attached to the subject, if present.
  public let ebookCount: Int?

  /// The works associated with this subject page.
  public let works: [OpenLibrarySubjectWork]

  /// Popular authors returned when `details=true`.
  public let authors: [OpenLibrarySubjectFacet]?

  /// Popular publishers returned when `details=true`.
  public let publishers: [OpenLibrarySubjectFacet]?

  /// Related subjects returned when `details=true`.
  public let subjects: [OpenLibrarySubjectFacet]?

  /// Related people returned when `details=true`.
  public let people: [OpenLibrarySubjectFacet]?

  /// Related places returned when `details=true`.
  public let places: [OpenLibrarySubjectFacet]?

  /// Related time periods returned when `details=true`.
  public let times: [OpenLibrarySubjectFacet]?

  /// Annual publishing counts returned when `details=true`.
  public let publishingHistory: [OpenLibrarySubjectPublishingHistoryPoint]?

  /// The first cover image URL associated with the subject's first work.
  public var coverImageURL: URL? {
    works.first?.coverImageURL
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    key = Self.normalizeSubjectKey(try container.decode(String.self, forKey: .key))
    name = try container.decode(String.self, forKey: .name)
    subjectType = try container.decode(String.self, forKey: .subjectType)
    workCount = try container.decode(Int.self, forKey: .workCount)
    ebookCount = try container.decodeIfPresent(Int.self, forKey: .ebookCount)
    works = try container.decodeIfPresent([OpenLibrarySubjectWork].self, forKey: .works) ?? []
    authors = try container.decodeIfPresent([OpenLibrarySubjectFacet].self, forKey: .authors)
    publishers = try container.decodeIfPresent([OpenLibrarySubjectFacet].self, forKey: .publishers)
    subjects = try container.decodeIfPresent([OpenLibrarySubjectFacet].self, forKey: .subjects)
    people = try container.decodeIfPresent([OpenLibrarySubjectFacet].self, forKey: .people)
    places = try container.decodeIfPresent([OpenLibrarySubjectFacet].self, forKey: .places)
    times = try container.decodeIfPresent([OpenLibrarySubjectFacet].self, forKey: .times)
    publishingHistory = try container.decodeIfPresent(
      [OpenLibrarySubjectPublishingHistoryPoint].self,
      forKey: .publishingHistory
    )
  }

  private static func normalizeSubjectKey(_ rawKey: String) -> String {
    if rawKey.starts(with: "/subjects/") {
      String(rawKey.dropFirst(10))
    } else {
      rawKey
    }
  }
}

/// A popular subject contributor returned in the expanded `details=true` view.
public struct OpenLibrarySubjectFacet: Decodable, Hashable, Sendable {
  enum CodingKeys: String, CodingKey {
    case count
    case name
    case key
  }

  /// The item count returned by Open Library.
  public let count: Int

  /// The item display name.
  public let name: String

  /// The optional normalized key for the item.
  public let key: String?

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    count = try container.decode(Int.self, forKey: .count)
    name = try container.decode(String.self, forKey: .name)

    if let rawKey = try container.decodeIfPresent(String.self, forKey: .key) {
      key = Self.normalizeKey(rawKey)
    } else {
      key = nil
    }
  }

  private static func normalizeKey(_ rawKey: String) -> String {
    if rawKey.starts(with: "/authors/") {
      String(rawKey.dropFirst(9))
    } else if rawKey.starts(with: "/subjects/") {
      String(rawKey.dropFirst(10))
    } else {
      rawKey
    }
  }
}

/// A subject work entry returned by Open Library.
public struct OpenLibrarySubjectWork: Decodable, Identifiable, Hashable, Sendable {
  enum CodingKeys: String, CodingKey {
    case key
    case title
    case editionCount = "edition_count"
    case authors
    case hasFullText = "has_fulltext"
    case ia
    case coverID = "cover_id"
  }

  /// The normalized work key without the `/works/` prefix.
  public var id: String { key }

  /// The normalized work key.
  public let key: String

  /// The work title.
  public let title: String

  /// The number of editions associated with the work.
  public let editionCount: Int?

  /// The authors attached to the work entry.
  public let authors: [OpenLibrarySubjectWorkAuthor]

  /// Whether full text is available for the work.
  public let hasFullText: Bool?

  /// The Internet Archive identifier when present.
  public let ia: String?

  /// The Open Library cover identifier when present.
  public let coverID: Int?

  /// A convenience cover image URL if the work exposes a cover ID.
  public var coverImageURL: URL? {
    guard let coverID else { return nil }
    return URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-L.jpg")
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    key = Self.normalizeWorkKey(try container.decode(String.self, forKey: .key))
    title = try container.decode(String.self, forKey: .title)
    editionCount = try container.decodeIfPresent(Int.self, forKey: .editionCount)
    authors =
      try container.decodeIfPresent([OpenLibrarySubjectWorkAuthor].self, forKey: .authors) ?? []
    hasFullText = try container.decodeIfPresent(Bool.self, forKey: .hasFullText)
    ia = try container.decodeIfPresent(String.self, forKey: .ia)
    coverID = try container.decodeIfPresent(Int.self, forKey: .coverID)
  }

  private static func normalizeWorkKey(_ rawKey: String) -> String {
    if rawKey.starts(with: "/works/") {
      String(rawKey.dropFirst(7))
    } else {
      rawKey
    }
  }
}

/// A subject work author entry.
public struct OpenLibrarySubjectWorkAuthor: Decodable, Hashable, Sendable {
  enum CodingKeys: String, CodingKey {
    case name
    case key
  }

  /// The author display name.
  public let name: String

  /// The normalized author key without the `/authors/` prefix.
  public let key: String

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)

    let rawKey = try container.decode(String.self, forKey: .key)
    if rawKey.starts(with: "/authors/") {
      key = String(rawKey.dropFirst(9))
    } else {
      key = rawKey
    }
  }
}

/// A year/count pair used by the expanded subject publishing history.
public struct OpenLibrarySubjectPublishingHistoryPoint: Decodable, Hashable, Sendable {
  /// The publication year.
  public let year: Int

  /// The number of works published in that year.
  public let count: Int

  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    year = try container.decode(Int.self)
    count = try container.decode(Int.self)
  }
}
