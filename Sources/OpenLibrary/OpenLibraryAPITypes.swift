//
//  OpenLibraryAPITypes.swift
//
//  Created by Natik Gadzhi
//

import Foundation

// MARK: - Common OpenLibrary API Types

/// OpenLibrary API specific timestamp format
/// Used in various API responses to represent creation and modification dates
public struct APITimestamp: Codable {
    /// Type of the timestamp, usually "/type/datetime"
    public let type: String
    
    /// The actual timestamp value as a string
    public let value: String
}

/// OpenLibrary API specific type reference
/// Used to reference various entities in the API responses (works, authors, etc.)
public struct TypeReference: Codable {
    /// The key identifying the referenced entity
    /// Usually in the format "/type/work", "/type/author", etc.
    public let key: String
}

/// OpenLibrary API specific description format
/// Used when the API returns a description with metadata
public struct DetailedDescription: Codable {
    /// Type of the description, usually "/type/text"
    public let type: String
    
    /// The actual description text
    public let value: String
}

/// OpenLibrary API specific language description
/// Used to represent languages in the API responses
public struct LanguageDescription: Codable {
    /// The language key, usually in the format "/languages/eng"
    public let key: String
    
    /// The three letter language code (e.g. "eng", "fra", "deu")
    /// Returns nil if the key is not in the expected format "/languages/XXX"
    public var languageCode: String? {
        guard key.starts(with: "/languages/"),
              key.count == 13 else { return nil }
        return String(key.dropFirst(10))
    }
}

/// OpenLibrary API specific chapter representation
/// Used in edition's table of contents
public struct Chapter: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case level
        case label
        case title
        case page = "pagenum"
    }

    /// Nesting level of the chapter
    public let level: Int
    
    /// Chapter label
    public let label: String
    
    /// Chapter title
    public let title: String
    
    /// Page number where the chapter starts
    public let page: String
}

// MARK: - Common Enums

/// OpenLibrary API book format
/// Used to represent different formats of books across the API
public enum BookFormat: String, Codable {
    case ebook
    case paper
    case audio
}

/// OpenLibrary API physical format
/// Represents the physical format of a book as returned by the API
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

/// Reference to an author
public struct AuthorReference: Codable {
    public let author: TypeReference
    public let type: TypeReference
}
