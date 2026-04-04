import Foundation
import Testing
import OpenLibrary

struct OpenLibraryWorkTests {
    @Test func testWorkDecodingSupportsWrappedDescriptionAndAuthorKeys() async throws {
        let json = """
        {
          "title": "Fantastic Mr Fox",
          "key": "/works/OL45804W",
          "authors": [
            {
              "author": { "key": "/authors/OL34184A" },
              "type": { "key": "/type/author_role" }
            }
          ],
          "description": {
            "type": "/type/text",
            "value": "A clever fox outwits three farmers."
          },
          "covers": [6498519],
          "subjects": ["Animals"],
          "created": {
            "type": "/type/datetime",
            "value": "2009-10-15T11:34:21.437031"
          }
        }
        """

        let work = try JSONDecoder().decode(OpenLibraryWork.self, from: Data(json.utf8))
        #expect(work.key == "OL45804W")
        #expect(work.description == "A clever fox outwits three farmers.")
        #expect(work.authorKeys == ["OL34184A"])
        #expect(work.coverImageURL?.absoluteString == "https://covers.openlibrary.org/b/id/6498519-L.jpg")
    }

    @Test func testOpenLibraryAPIWorkEndpoint() async throws {
        let api = OpenLibraryAPI()
        let work = try await api.getWork(workKey: "OL45804W")

        #expect(work.key == "OL45804W")
        #expect(!work.title.isEmpty)
    }
}
