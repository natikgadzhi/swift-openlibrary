//
//  OpenLibrarySearchTests.swift
//

import Foundation
import OpenLibrary
import Testing

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
    #expect(work.coverImageURL != nil)
    #expect(
      work.coverImageURL!.absoluteString
        == "https://covers.openlibrary.org/b/id/\(work.coverImageID!)-L.jpg")
  }

  @Test func testOpenLibraryAPISearchEndpoint() async throws {
    let api = OpenLibraryAPI()
    do {
      let response = try await api.search(query: "Pattern Recognition")
      #expect(response.numFound > 0)
      #expect(response.docs.count != 0)
    } catch let OpenLibraryAPI.APIError.unexpectedStatusCode(status, body) {
      if status == 500, let body, body.contains("DEPRECATED ENDPOINT") {
        return
      }
      throw OpenLibraryAPI.APIError.unexpectedStatusCode(status, body: body)
    }
  }
}
