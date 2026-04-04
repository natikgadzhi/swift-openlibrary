import Testing
import OpenLibrary

struct OpenLibraryCoversTests {
    @Test func testBookCoverIDURLUsesExpectedFormat() {
        let url = OpenLibraryCovers.bookURL(for: .coverID(9238695), size: .large)
        #expect(url?.absoluteString == "https://covers.openlibrary.org/b/id/9238695-L.jpg")
    }

    @Test func testBookEditionKeyURLUsesExpectedFormat() {
        let url = OpenLibraryCovers.bookURL(for: .editionKey("OL27847723M"), size: .medium)
        #expect(url?.absoluteString == "https://covers.openlibrary.org/b/olid/OL27847723M-M.jpg")
    }

    @Test func testBookISBNURLPreservesIdentifier() {
        let url = OpenLibraryCovers.bookURL(for: .isbn("9780300234176"), size: .small)
        #expect(url?.absoluteString == "https://covers.openlibrary.org/b/isbn/9780300234176-S.jpg")
    }

    @Test func testAuthorPhotoURLUsesExpectedFormat() {
        let url = OpenLibraryCovers.authorPhotoURL(for: .authorKey("OL23919A"), size: .large)
        #expect(url?.absoluteString == "https://covers.openlibrary.org/a/olid/OL23919A-L.jpg")
    }
}
