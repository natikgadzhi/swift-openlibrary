import Foundation
import Testing
import OpenLibrary

@Suite("OpenLibrary work ratings and bookshelves")
struct OpenLibraryWorkExtrasTests {
    @Test func testRatingsDecoding() async throws {
        let json = """
        {"summary":{"average":4.203438395415473,"count":1047,"sortable":4.129946372357495},"counts":{"1":112,"2":35,"3":64,"4":153,"5":683}}
        """

        let response = try JSONDecoder().decode(
            OpenLibraryWorkRatingsResponse.self,
            from: Data(json.utf8)
        )

        #expect(response.ratingCount == 1047)
        #expect(response.averageRating == 4.203438395415473)
        #expect(response.counts[stars: 5] == 683)
    }

    @Test func testBookshelvesDecoding() async throws {
        let json = """
        {"counts":{"want_to_read":40102,"currently_reading":2586,"already_read":1330}}
        """

        let response = try JSONDecoder().decode(
            OpenLibraryWorkBookshelvesResponse.self,
            from: Data(json.utf8)
        )

        #expect(response.counts.wantToRead == 40102)
        #expect(response.counts.currentlyReading == 2586)
        #expect(response.counts.alreadyRead == 1330)
        #expect(response.totalCount == 44018)
    }

    @Test func testOpenLibraryAPIWorkRatingsEndpoint() async throws {
        let api = OpenLibraryAPI()
        let response = try await api.getWorkRatings(workKey: "OL18020194W")

        #expect(response.ratingCount > 0)
        #expect(response.counts[stars: 5] ?? 0 > 0)
    }

    @Test func testOpenLibraryAPIWorkBookshelvesEndpoint() async throws {
        let api = OpenLibraryAPI()
        let response = try await api.getWorkBookshelves(workKey: "OL18020194W")

        #expect(response.totalCount > 0)
        #expect(response.counts.wantToRead > 0)
    }
}
