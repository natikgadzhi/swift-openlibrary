//
//  OpenLibrarySearch.swift
//
//  Created by Natik Gadzhi on 12/23/24.
//

import Foundation

/// A paginated Open Library search response.
///
/// Open Library search results contain both pagination metadata and an array of
/// work-shaped documents. This envelope is the preferred return type for search
/// APIs because it preserves `start` and `numFound` for callers that need to
/// page or present total-result counts.
public struct OpenLibrarySearchResults: Decodable, Sendable {
  /// The zero-based offset for this page.
  public let start: Int

  /// The total number of matching records.
  public let numFound: Int

  /// Whether the total record count is exact.
  public let numFoundExact: Bool?

  /// The search documents for this page.
  public let docs: [OpenLibrarySearchResult]

  /// A convenience alias for ``docs``.
  public var results: [OpenLibrarySearchResult] { docs }

  enum CodingKeys: String, CodingKey {
    case start
    case numFound
    case numFoundSnakeCase = "num_found"
    case numFoundExact
    case numFoundExactSnakeCase = "num_found_exact"
    case docs
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    start = try container.decodeIfPresent(Int.self, forKey: .start) ?? 0
    numFound =
      try container.decodeIfPresent(Int.self, forKey: .numFound)
      ?? container.decode(Int.self, forKey: .numFoundSnakeCase)
    numFoundExact =
      try container.decodeIfPresent(Bool.self, forKey: .numFoundExact)
      ?? container.decodeIfPresent(Bool.self, forKey: .numFoundExactSnakeCase)
    docs = try container.decode([OpenLibrarySearchResult].self, forKey: .docs)
  }
}

/// A backwards-compatible alias for the pre-pagination response name.
public typealias OpenLibrarySearchResponse = OpenLibrarySearchResults

/// A work-shaped search document returned by `/search.json`.
public struct OpenLibrarySearchResult: Decodable, Identifiable, Hashable, Sendable {

  enum CodingKeys: String, CodingKey {
    case key
    case title
    case subtitle
    case authorNames = "author_name"
    case authorKeys = "author_key"
    case coverImageID = "cover_i"
    case editionCount = "edition_count"
    case firstPublishYear = "first_publish_year"
    case editionISBNs = "isbn"
    case editionKeys = "edition_key"
    case language
    case hasFullText = "has_fulltext"
    case publicScan = "public_scan_b"
    case asin = "id_amazon"
    case wikidataID = "id_wikidata"
    case subjects = "subject"
  }

  /// The normalized work identifier without the `/works/` prefix.
  public var id: String { key }

  /// The normalized work key.
  public let key: String

  /// The work title.
  public let title: String

  /// The work subtitle if present.
  public let subtitle: String?

  /// The author names returned on the search document.
  public let authorNames: [String]?

  /// The normalized author keys returned on the search document.
  public let authorKeys: [String]?

  /// The Open Library cover identifier.
  public let coverImageID: Int?

  /// The number of editions attached to the work.
  public let editionCount: Int?

  /// The earliest publication year returned by search.
  public let firstPublishYear: Int?

  /// ISBN values surfaced through search.
  public let editionISBNs: [String]?

  /// Edition keys surfaced through search.
  public let editionKeys: [String]?

  /// Language codes attached to the search document.
  public let language: [String]?

  /// Whether full text is available.
  public let hasFullText: Bool?

  /// Whether a public scan exists.
  public let publicScan: Bool?

  /// Amazon identifiers surfaced through search.
  public let asin: [String]?

  /// Wikidata identifiers surfaced through search.
  public let wikidataID: [String]?

  /// Subject tags surfaced through search.
  public let subjects: [String]?

  /// The large cover image URL if a cover identifier is present.
  public var coverImageURL: URL? {
    guard let coverImageID else { return nil }
    return URL(string: "https://covers.openlibrary.org/b/id/\(coverImageID)-L.jpg")
  }

  /// The first author name if one is present.
  public var author: String? {
    authorNames?.first
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let prefixedWorkKey = try container.decode(String.self, forKey: .key)
    if prefixedWorkKey.starts(with: "/works/") {
      key = String(prefixedWorkKey.dropFirst(7))
    } else {
      key = prefixedWorkKey
    }

    title = try container.decode(String.self, forKey: .title)
    subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
    authorNames = try container.decodeIfPresent([String].self, forKey: .authorNames)
    authorKeys = try container.decodeIfPresent([String].self, forKey: .authorKeys)
    coverImageID = try container.decodeIfPresent(Int.self, forKey: .coverImageID)
    editionCount = try container.decodeIfPresent(Int.self, forKey: .editionCount)
    firstPublishYear = try container.decodeIfPresent(Int.self, forKey: .firstPublishYear)
    editionISBNs = try container.decodeIfPresent([String].self, forKey: .editionISBNs)
    editionKeys = try container.decodeIfPresent([String].self, forKey: .editionKeys)
    language = try container.decodeIfPresent([String].self, forKey: .language)
    hasFullText = try container.decodeIfPresent(Bool.self, forKey: .hasFullText)
    publicScan = try container.decodeIfPresent(Bool.self, forKey: .publicScan)
    asin = try container.decodeIfPresent([String].self, forKey: .asin)
    wikidataID = try container.decodeIfPresent([String].self, forKey: .wikidataID)
    subjects = try container.decodeIfPresent([String].self, forKey: .subjects)
  }
}
