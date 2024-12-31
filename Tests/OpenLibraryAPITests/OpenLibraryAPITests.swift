//
//  OpenLibraryAPITests.swift
//
//  Created by Natik Gadzhi on 12/21/24.
//

import Foundation
import Testing
import OpenLibrary

struct OpenLibraryAPITests {

    // MARK: - Search tests

    @Test func testSearchAPIResponse() async throws {
        let response = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: OpenLibraryAPIMocks.search.data(using: .utf8)!)
        #expect(response.docs.count == 1)
    }

    @Test func testSearchReturnsBookWithCorrectImageAndAuthor() async throws {
        let response = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: OpenLibraryAPIMocks.search.data(using: .utf8)!)
        let work = response.docs.first!
        #expect( work.coverImageURL != nil )
        #expect( work.coverImageURL!.absoluteString == "https://covers.openlibrary.org/b/id/\(work.coverImageID!)-L.jpg")
    }

    @Test func testOpenLibraryAPISearchEndpoint() async throws {
        let api = OpenLibraryAPI()
        let books = try await api.searchBooks(query: "Pattern Recognition")
        #expect(books.count != 0)

        print(books.first!.key)
    }

    // MARK: - Editions tests

    @Test func testEditionsAPIResponse() async throws {
        let response = try JSONDecoder().decode(
            OpenLibraryEditionsResponse.self,
            from: OpenLibraryAPIMocks.twitterAndTearGasEditions.data(using: .utf8)!
        )

        #expect(response.entries.count == 4)
    }

    @Test func testOpenLibraryAPIEditionsEndpoint() async throws {
        // Pattern Recognition work key — has some wonky editions
        let key = "OL15014715W"

        let api = OpenLibraryAPI()
        let editions = try await api.getWorkEditions(workKey: key)

        #expect(editions.count != 0)
    }

    @Test func testEditionsHaveCoverImages() async throws {
        let response = try JSONDecoder().decode(
            OpenLibraryEditionsResponse.self,
            from: OpenLibraryAPIMocks.twitterAndTearGasEditions.data(using: .utf8)!
        )

        for edition in response.entries.filter({ $0.coverImageIDs != nil }) {
            #expect(edition.coverImageURL != nil)
        }
    }

    @Test func testEditionsFormatWherePhysicalFormatIsMP3() async throws {
        let response = try JSONDecoder().decode(
            OpenLibraryEditionsResponse.self,
            from: OpenLibraryAPIMocks.twitterAndTearGasEditions.data(using: .utf8)!
        )

        for edition in response.entries.filter({ $0.physicalFormat == .audioCD }) {
            #expect(edition.format == .audio, "Expected Edition \(edition.key) to be audio format, received \(edition.format)")
        }
    }

    @Test func testEditionsFormatIsPaperForBWBooksWitoutKindleID() async throws {
        let response = try JSONDecoder().decode(
            OpenLibraryEditionsResponse.self,
            from: OpenLibraryAPIMocks.twitterAndTearGasEditions.data(using: .utf8)!
        )

        for edition in response.entries
            .filter({ !($0.asin?.starts(with: "B0") ?? false) && $0.sourceRecords?.contains(where: { $0.starts(with: "bwb")}) ?? false }) {
            #expect(edition.format == .paper)
        }
    }


    @Test func testEditionsASINMatchesAmazonIdentifier() async throws {
        let response = try JSONDecoder().decode(
            OpenLibraryEditionsResponse.self,
            from: OpenLibraryAPIMocks.twitterAndTearGasEditions.data(using: .utf8)!
        )

        for edition in response.entries.filter({ $0.identifiers?.keys.contains("amazon") ?? false }) {
            #expect(edition.asin == edition.identifiers?["amazon"]?.first)
        }
    }

    @Test func testEditionsASINIsNilIfNoAmazonID() async throws {
        let response = try JSONDecoder().decode(
            OpenLibraryEditionsResponse.self,
            from: OpenLibraryAPIMocks.twitterAndTearGasEditions.data(using: .utf8)!
        )

        for edition in response.entries.filter({ !($0.identifiers?.keys.contains("amazon") ?? false) }) {
            #expect(edition.asin == nil)
        }
    }

    @Test func testEditionsFormatIsElectronicIfAsinStartsWithB0() async throws {
        let response = try JSONDecoder().decode(
            OpenLibraryEditionsResponse.self,
            from: OpenLibraryAPIMocks.twitterAndTearGasEditions.data(using: .utf8)!
        )

        // Filter out all books with bwb: in their source records, as this takes precedence over ASINs
        let nonBWB = response.entries.filter({ !($0.sourceRecords?.contains(where: { $0.starts(with: "bwb")}) ?? false) })
        for edition in nonBWB.filter({ $0.identifiers?.keys.contains("amazon") ?? false }) {
            if let asin = edition.asin {
                if asin.starts(with: "B00") || asin.starts(with: "B01") {
                    #expect(edition.format == .ebook)
                }
            }
        }
    }

    @Test func testEditionsFormatWherePhysicalFormatIsPaperback() async throws {
        let response = try JSONDecoder().decode(
            OpenLibraryEditionsResponse.self,
            from: OpenLibraryAPIMocks.twitterAndTearGasEditions.data(using: .utf8)!
        )

        for edition in response.entries.filter({ $0.physicalFormat == .paperback }) {
            #expect(edition.format == .paper)
        }
    }
}
