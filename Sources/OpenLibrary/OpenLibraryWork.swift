//
//  OpenLibraryWork.swift
//
//  Created by Natik Gadzhi on 12/23/24.
//

import Foundation


/// Describes OpenLibrary API Search response.
/// I.e. https://openlibrary.org/search.json?q=
///
/// TODO:
///     - This has more fields available, i.e. num_found etc.
///     - Consider adding pagination to the corresponding method
///
public struct OpenLibrarySearchResponse: Codable {
    public let docs: [OpenLibraryWork]
}


/// Describes an OpenLibrary Book as a "Worl", meaning — this includes
/// all available editions, including audiobooks, paperbacks, and electronic books.
///
public struct OpenLibraryWork: Codable, Identifiable, Hashable, Sendable {

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorNames = "author_name"
        case coverImageID = "cover_i"
        case editionISBNs = "isbn"
        case editionKeys = "edition_key"
        case asin = "id_amazon"
        case wikidataID = "id_wikidata"
        case subjects = "subject"
    }

    /// Work ID is it's `key` field.
    ///
    public var id: String { key }

    /// An OpenLibrary work key, usually `OL20057658W` or similar, without the `/works/` prefix.
    public let key: String

    /// Book title
    public let title: String

    /// Author name(s)
    public let authorNames: [String]?

    /// OpenLibrary cover integer index
    public let coverImageID: Int?

    /// An array of ISBNs of different editions of this book
    public let editionISBNs: [String]?

    /// An array of OpenLibrary edition keys, without `/work` prefix
    public let editionKeys: [String]?

    /// An array of ASINs
    public let asin: [String]?

    /// An array of Wikidata work IDs
    public let wikidataID: [String]?

    /// An array of subjects for this book from OpenLibrary
    public let subjects: [String]?

    /// Returns a URL for the cover image that is ready to present
    public var coverImageURL: URL? {
        guard let coverImageID = coverImageID else { return nil }
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverImageID)-L.jpg")
    }

    /// Single author string
    public var author: String? {
        authorNames?.first
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Remove the work key `/works/` prefix if it exists
        let prefixedWorkKey = try container.decode(String.self, forKey: .key)
        if prefixedWorkKey.starts(with: "/works/") {
            key = String(prefixedWorkKey.dropFirst(7)) }
        else {
            key = prefixedWorkKey
        }

        title = try container.decode(String.self, forKey: .title)
        authorNames = try container.decodeIfPresent([String].self, forKey: .authorNames)
        coverImageID = try container.decodeIfPresent(Int.self, forKey: .coverImageID)
        editionISBNs = try container.decodeIfPresent([String].self, forKey: .editionISBNs)
        editionKeys = try container.decodeIfPresent([String].self, forKey: .editionKeys)
        asin = try container.decodeIfPresent([String].self, forKey: .asin)
        wikidataID = try container.decodeIfPresent([String].self, forKey: .wikidataID)
        subjects = try container.decodeIfPresent([String].self, forKey: .subjects)
    }

}

