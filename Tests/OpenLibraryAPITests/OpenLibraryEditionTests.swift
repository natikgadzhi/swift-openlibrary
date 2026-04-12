import Foundation
import OpenLibrary
import Testing

struct OpenLibraryEditionTests {
  @Test func testEditionDecodingSupportsWrappedDescriptionAndLanguage() async throws {
    let json = """
      {
        "key": "/books/OL20057658M",
        "title": "Twitter and Tear Gas",
        "subtitle": "The Power and Fragility of Networked Protest",
        "description": {
          "type": "/type/text",
          "value": "A firsthand account of modern protest."
        },
        "publish_date": "2021",
        "covers": [10656197],
        "physical_format": "mp3 cd",
        "identifiers": {
          "amazon": ["B06XR259MG"]
        },
        "language": {
          "key": "/languages/eng"
        }
      }
      """

    let edition = try JSONDecoder().decode(OpenLibraryEdition.self, from: Data(json.utf8))
    #expect(edition.key == "/books/OL20057658M")
    #expect(edition.title == "Twitter and Tear Gas")
    #expect(edition.description == "A firsthand account of modern protest.")
    #expect(edition.language == "eng")
    #expect(edition.publicationYear == "2021")
    #expect(
      edition.coverImageURL?.absoluteString == "https://covers.openlibrary.org/b/id/10656197-L.jpg")
  }

  @Test func testOpenLibraryAPISingleEditionEndpoint() async throws {
    let editionJSON = """
      {
        "key": "/books/OL20057658M",
        "title": "Twitter and Tear Gas",
        "subtitle": "The Power and Fragility of Networked Protest",
        "description": "A firsthand account of modern protest.",
        "publish_date": "2021",
        "covers": [10656197],
        "physical_format": "mp3 cd",
        "identifiers": {
          "amazon": ["B06XR259MG"]
        },
        "language": {
          "key": "/languages/eng"
        }
      }
      """

    let session = SessionStub { request in
      let url = try #require(request.url)
      #expect(url.absoluteString == "https://example.com/books/OL20057658M.json")

      return (
        Data(editionJSON.utf8),
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
      )
    }

    let api = OpenLibraryAPI(
      configuration: .init(
        baseURL: URL(string: "https://example.com")!,
        session: session
      )
    )

    let edition = try await api.getEdition(editionKey: "/books/OL20057658M")
    #expect(edition.key == "/books/OL20057658M")
    #expect(edition.asin == "B06XR259MG")
    #expect(
      edition.coverImageURL?.absoluteString == "https://covers.openlibrary.org/b/id/10656197-L.jpg")
  }

  @Test func testOpenLibraryAPISingleEditionEndpointLive() async throws {
    let api = OpenLibraryAPI()
    let edition = try await api.getEdition(editionKey: "OL20057658M")

    #expect(edition.key.starts(with: "/books/"))
    #expect(!edition.title.isEmpty)
    if let coverURL = edition.coverImageURL {
      #expect(coverURL.scheme == "https")
    }
  }
}
