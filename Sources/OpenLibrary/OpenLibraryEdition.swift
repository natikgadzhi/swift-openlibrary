//
//  OpenLibraryEdition.swift
//
//  Created by Natik Gadzhi on 12/23/24.
//

import Foundation

/// Describes OpenLibrary API Editions response
/// i.e. https://openlibrary.org/works/OL20057658W/editions.json
public struct OpenLibraryEditionsResponse: Codable {
    public let entries: [OpenLibraryEdition]
}

/// Describes one particular edition of a ``OpenLibraryWork``
///
public struct OpenLibraryEdition: Codable, Identifiable, Sendable{

    /// Edition ID is it's `key` field.
    ///
    public var id: String { key }

    /// Edition identifier key
    /// i.e. `/books/OL20057658M`
    ///
    public let key: String

    /// Title of this edition of the book
    ///
    public let title: String

    /// Subtitle of this edition.
    ///
    public let subtitle: String?

    /// Description of this edition of a book. It's not always there.
    /// { type: ..., value: "string" }
    ///
    public let description: String?

    /// This edition's publication date. Format varies, but usualy this is a year.
    ///
    public let publishDate: String?

    /// If present, the number of pages in this edition.
    /// If number of pages is present, it's very likely this is a paper book edition.
    ///
    public let numberOfPages: Int?

    /// A string containing pagination information.
    /// It can be opportunistically convertable into a number, i.e. `"360"`,
    /// but can be tricky, i.e. `"xxxi, 326 pages"`.
    ///
    public let pagination: String?

    /// How much does this edition weight? If this is present, this is a physical copy.
    /// Could be an mp3 disc or a book.
    /// The API returns this as string, but it should be convertable to a number.
    ///
    public let weight: String?

    /// Physical format of this edition.
    ///
    public let physicalFormat: PhysicalFormat?

    /// Map of edition identifiers on other platforms where this edition is available.
    /// { "amazon": ["ASIN"] }
    ///
    public let identifiers: [String: [String]]?

    /// An array of strings describing this book edition subjects.
    /// Typically should match the whole work subjects, but /shrug.
    ///
    public let subjects: [String]?

    /// An array of strings describing sources for this edition record on Open Library.
    /// Each string comes as `source:identifier` format, for example `amazon:ASIN`.
    ///
    /// `bwb` stands for Better World Books, and usually means this edition is a paper book.
    ///
    public let sourceRecords: [String]?

    /// An array of cover identifiers. A cover ID is an integer that can be converted to a URL to fetch a cover image.
    ///
    public let coverImageIDs: [Int]?

    /// ISBN10, if present.
    ///
    public let isbn10: String?

    /// ISBN13, if present.
    ///
    public let isbn13: String?

    /// Identifier of this edition in the Library of Congress, if present.
    ///
    public let iccn: [String]?

    /// Identifier of this edition in the OCLC WorldCat, if present.
    ///
    public let oclc: [String]?

    /// Table of contents of this edition
    ///
    public let tableOfContents: [Chapter]?

    /// Three-letter (iso639_2) language code of this edition.
    ///
    public let language: String?

    // MARK: - Computer Properties

    /// Returns valid cover images for this Edition
    ///
    public var coverImageURLs: [URL] {
        guard let coverImageIDs = coverImageIDs else { return [] }
        return coverImageIDs.map { URL(string: "https://covers.openlibrary.org/b/id/\($0)-L.jpg")! }
    }

    /// First valid cover URL for this Edition
    ///
    public var coverImageURL: URL? {
        coverImageURLs.first
    }

    /// Returns the first edition ASIN based on the `identifiers` json key
    ///
    public var asin: String? {
        identifiers?["amazon"]?.first
    }

    /// Returns the inferred format of the book if possible
    ///
    public var format: BookFormat? {

        // physical format flag is the best way to detect the actual format of the edition
        if let physicalFormat = physicalFormat {
            switch physicalFormat {
            case .paperback, .hardcover: return .paper
            case .mp3CD, .audioCD: return .audio
            case .ebook: return .ebook
            }
        }

        // Check if we have an Amazon ASIN starting with B00 or B01
        // Those usually signify a Kindle book
        if let asin = asin {
            if asin.starts(with: "B0") {
                return .ebook
            }
        }

        // Check if we have a source record from better world books
        if let sourceRecords = sourceRecords {
            if sourceRecords.contains(where: { $0.hasPrefix("bwb:") }) {
                return .paper
            }
        }

        return nil
    }

    public var publicationYear: String? {
        let regex = try! Regex("\\b\\d{4}\\b")
        return publishDate?.firstMatch(of: regex)?.0.description
    }
}

// MARK: - Coding Keys and Decoding

extension OpenLibraryEdition {
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case subtitle
        case description
        case publishDate = "publish_date"
        case numberOfPages = "number_of_pages"
        case pagination
        case identifiers
        case subjects
        case sourceRecords = "source_records"
        case coverImageIDs = "covers"
        case physicalFormat = "physical_format"
        case weight
        case isbn10, isbn13, iccn, oclc
        case tableOfContents = "table_of_contents"
        case language
    }

    /// A custom init to support `description` optionally being a string.
    ///
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode regular properties
        self.key = try container.decode(String.self, forKey: .key)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.publishDate = try container.decodeIfPresent(String.self, forKey: .publishDate)
        self.numberOfPages = try container.decodeIfPresent(Int.self, forKey: .numberOfPages)
        self.pagination = try container.decodeIfPresent(String.self, forKey: .pagination)
        self.weight = try container.decodeIfPresent(String.self, forKey: .weight)
        self.physicalFormat = try container.decodeIfPresent(
            PhysicalFormat.self, forKey: .physicalFormat)
        self.identifiers = try container.decodeIfPresent(
            [String: [String]].self, forKey: .identifiers)
        self.subjects = try container.decodeIfPresent([String].self, forKey: .subjects)
        self.sourceRecords = try container.decodeIfPresent([String].self, forKey: .sourceRecords)
        self.coverImageIDs = try container.decodeIfPresent([Int].self, forKey: .coverImageIDs)
        self.isbn10 = try container.decodeIfPresent([String].self, forKey: .isbn10)?.first
        self.isbn13 = try container.decodeIfPresent([String].self, forKey: .isbn13)?.first
        self.iccn = try container.decodeIfPresent([String].self, forKey: .iccn)
        self.oclc = try container.decodeIfPresent([String].self, forKey: .oclc)
        self.tableOfContents = try container.decodeIfPresent(
            [Chapter].self, forKey: .tableOfContents)

        // Custom decoding for description field that can be either a Description object or a String
        if let descriptionObject = try? container.decodeIfPresent(
            Description.self, forKey: .description)
        {
            self.description = descriptionObject.value
        } else if let descriptionString = try? container.decodeIfPresent(
            String.self, forKey: .description)
        {
            // Create a Description object from the plain string
            self.description = descriptionString
        } else {
            self.description = nil
        }

        if let language = try? container.decodeIfPresent(
            LanguageDescription.self, forKey: .language)
        {
            self.language = language.key.split(separator: "/").last?.description
        } else {
            self.language = nil
        }
    }
}

// MARK: - Supporting Types

extension OpenLibraryEdition {

    public struct LanguageDescription: Codable {
        let key: String
    }

    /// OpenLibrary field wrapped in a type + value struct
    ///
    public struct Description: Codable {
        let type: String
        let value: String
    }

    /// Represents a single chapter in an edition Table of Contents
    ///
    public struct Chapter: Codable, Sendable {

        enum CodingKeys: String, CodingKey {
            case level
            case label
            case title
            case page = "pagenum"
        }

        let level: Int
        let label: String
        let title: String
        let page: String
    }

    /// Describes a wrapped date time type
    ///
    public struct OLDateTime: Codable {
        let type: String
        let value: Date
    }

    /// Describes possible book formats, agnostic of the book provider
    ///
    public enum BookFormat: String, Codable {
        case ebook
        case paper
        case audio
    }

    /// Describes an edition physical format
    ///
    public enum PhysicalFormat: String, Codable, CaseIterable, Sendable {
        case mp3CD = "mp3 cd"
        case paperback = "paperback"
        case hardcover = "hardcover"
        case ebook = "ebook"
        case audioCD = "audio cd"

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawString = try container.decode(String.self)

            // Convert to lowercase for case-insensitive matching
            let lowercased = rawString.lowercased()

            // Try to initialize with the lowercased string
            guard let format = PhysicalFormat(rawValue: lowercased) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription:
                        "Invalid physical format: '\(rawString)'. Expected one of: \(PhysicalFormat.allCases.map { $0.rawValue }.joined(separator: ", "))"
                )
            }

            self = format
        }
    }

}
