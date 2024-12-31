//
//  OpenLibrarySearchTests.swift
//

import Foundation
import Testing
import OpenLibrary

struct OpenLibrarySearchTests {
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
} 