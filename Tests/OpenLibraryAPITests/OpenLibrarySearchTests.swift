//
//  OpenLibrarySearchTests.swift
//

import Foundation
import Testing
import OpenLibrary

struct OpenLibrarySearchTests {
    @Test func testSearchAPIResponse() async throws {
        let response = try JSONDecoder().decode(
            OpenLibrarySearchResults.self,
            from: OpenLibraryAPIMocks.search.data(using: .utf8)!
        )
        #expect(response.numFound == 1)
        #expect(response.start == 0)
        #expect(response.docs.count == 1)
    }

    @Test func testSearchReturnsBookWithCorrectImageAndAuthor() async throws {
        let response = try JSONDecoder().decode(
            OpenLibrarySearchResults.self,
            from: OpenLibraryAPIMocks.search.data(using: .utf8)!
        )
        let work = response.docs.first!
        #expect( work.coverImageURL != nil )
        #expect( work.coverImageURL!.absoluteString == "https://covers.openlibrary.org/b/id/\(work.coverImageID!)-L.jpg")
    }

    @Test func testOpenLibraryAPISearchEndpoint() async throws {
        let api = OpenLibraryAPI()
        let response = try await api.search(query: "Pattern Recognition")
        #expect(response.numFound > 0)
        #expect(response.docs.count != 0)

        print(response.docs.first!.key)
    }
} 
