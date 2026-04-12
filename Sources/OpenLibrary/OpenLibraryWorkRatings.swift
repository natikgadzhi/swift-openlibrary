//
//  OpenLibraryWorkRatings.swift
//
//  Created by Natik Gadzhi on 4/4/26.
//

import Foundation

/// A typed representation of `/works/{id}/ratings.json`.
///
/// Open Library exposes both a summary block and a star histogram for each work.
/// This model keeps both parts available to callers without forcing them to parse
/// dynamic dictionaries.
public struct OpenLibraryWorkRatingsResponse: Decodable, Sendable {
  /// The aggregate rating summary.
  public let summary: Summary

  /// The number of ratings at each star level.
  public let counts: RatingHistogram

  /// The average star rating.
  public var averageRating: Double {
    summary.average
  }

  /// The number of ratings represented in the summary.
  public var ratingCount: Int {
    summary.count
  }

  /// Creates a ratings response from JSON returned by Open Library.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    summary = try container.decode(Summary.self, forKey: .summary)
    counts = try container.decode(RatingHistogram.self, forKey: .counts)
  }

  private enum CodingKeys: String, CodingKey {
    case summary
    case counts
  }
}

extension OpenLibraryWorkRatingsResponse {
  /// The aggregate summary returned alongside the histogram.
  public struct Summary: Decodable, Sendable {
    /// The arithmetic mean of all ratings.
    public let average: Double

    /// The number of ratings included in the summary.
    public let count: Int

    /// A sortable representation of the average.
    public let sortable: Double
  }

  /// A typed five-star histogram.
  public struct RatingHistogram: Decodable, Sendable {
    /// The count for one-star ratings.
    public let one: Int

    /// The count for two-star ratings.
    public let two: Int

    /// The count for three-star ratings.
    public let three: Int

    /// The count for four-star ratings.
    public let four: Int

    /// The count for five-star ratings.
    public let five: Int

    /// Creates a histogram from the numeric-string keyed JSON object returned by Open Library.
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      one = try container.decode(Int.self, forKey: .one)
      two = try container.decode(Int.self, forKey: .two)
      three = try container.decode(Int.self, forKey: .three)
      four = try container.decode(Int.self, forKey: .four)
      five = try container.decode(Int.self, forKey: .five)
    }

    /// Returns the count for a specific star value.
    public subscript(stars stars: Int) -> Int? {
      switch stars {
      case 1: one
      case 2: two
      case 3: three
      case 4: four
      case 5: five
      default: nil
      }
    }

    private enum CodingKeys: String, CodingKey {
      case one = "1"
      case two = "2"
      case three = "3"
      case four = "4"
      case five = "5"
    }
  }
}
