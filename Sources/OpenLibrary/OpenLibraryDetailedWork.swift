//
//  OpenLibraryDetailedWork.swift
//
//  Created by Natik Gadzhi
//

import Foundation

/// Represents a detailed work from the OpenLibrary Works API
/// This is different from the search result work as it contains more detailed information
public struct OpenLibraryWork: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case description
        case covers
        case subjects
        case subjectPlaces = "subject_places"
        case subjectTimes = "subject_times"
        case subjectPeople = "subject_people"
        case authors
        case firstPublishDate = "first_publish_date"
        case type
        case latestRevision = "latest_revision"
        case revision
        case created
        case lastModified = "last_modified"
    }
    
    /// Conformes to Identifiable by using `key` as ID.
    public var id: String { key } 
    
    /// The work's key (e.g. "/works/OL45804W")
    public let key: String
    
    /// The work's title
    public let title: String
    
    /// The work's description, can be either a string or an object with additional fields
    public let description: WorkDescription?
    
    /// Array of cover image IDs
    public let covers: [Int]?
    
    /// The work's subjects
    public let subjects: [String]?
    
    /// Places mentioned in or related to the work
    public let subjectPlaces: [String]?
    
    /// Time periods mentioned in or related to the work
    public let subjectTimes: [String]?
    
    /// People mentioned in or related to the work
    public let subjectPeople: [String]?
    
    /// Authors of the work
    public let authors: [AuthorReference]?
    
    /// Date when the work was first published
    public let firstPublishDate: String?
    
    /// Type of the document (usually "/type/work")
    public let type: TypeReference
    
    /// Latest revision number
    public let latestRevision: Int
    
    /// Current revision number
    public let revision: Int
    
    /// Creation timestamp
    public let created: APITimestamp
    
    /// Last modification timestamp
    public let lastModified: APITimestamp
    
    /// Returns URLs for all cover images
    public var coverImageURLs: [URL]? {
        covers?.map { coverID in
            URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-L.jpg")!
        }
    }
}

/// Represents a work's description which can be either a string or an object
public enum WorkDescription: Codable {
    case text(String)
    case detailed(DetailedDescription)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .text(string)
        } else {
            let detailed = try container.decode(DetailedDescription.self)
            self = .detailed(detailed)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .text(let string):
            try container.encode(string)
        case .detailed(let detailed):
            try container.encode(detailed)
        }
    }
}