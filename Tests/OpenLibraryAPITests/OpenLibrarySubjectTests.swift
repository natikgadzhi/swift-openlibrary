import Foundation
import Testing
import OpenLibrary

struct OpenLibrarySubjectTests {
    @Test func testSubjectDecoding() async throws {
        let subject = try JSONDecoder().decode(
            OpenLibrarySubject.self,
            from: OpenLibraryAPIMocks.loveSubject.data(using: .utf8)!
        )

        #expect(subject.key == "love")
        #expect(subject.name == "Love")
        #expect(subject.subjectType == "subject")
        #expect(subject.workCount == 4918)
        #expect(subject.ebookCount == 497)
        #expect(subject.works.count == 1)
        #expect(subject.works.first?.key == "OL66534W")
        #expect(subject.works.first?.authors.first?.key == "OL21594A")
        #expect(subject.authors?.first?.key == "OL12823A")
        #expect(subject.publishingHistory?.first?.year == 1492)
        #expect(subject.publishingHistory?.first?.count == 2)
    }

    @Test func testOpenLibraryAPISubjectEndpoint() async throws {
        let session = SubjectSessionStub { request in
            let url = try #require(request.url)
            let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))

            #expect(components.scheme == "https")
            #expect(components.host == "example.com")
            #expect(components.path == "/subjects/love.json")
            #expect(components.queryItems?.first(where: { $0.name == "details" })?.value == "true")
            #expect(components.queryItems?.first(where: { $0.name == "ebooks" })?.value == "true")
            #expect(components.queryItems?.first(where: { $0.name == "published_in" })?.value == "1500-1600")
            #expect(components.queryItems?.first(where: { $0.name == "limit" })?.value == "10")
            #expect(components.queryItems?.first(where: { $0.name == "offset" })?.value == "20")

            return (
                Data(OpenLibraryAPIMocks.loveSubject.utf8),
                HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            )
        }

        let api = OpenLibraryAPI(
            configuration: .init(
                baseURL: URL(string: "https://example.com")!,
                session: session
            )
        )

        let subject = try await api.getSubject(
            subjectSlug: "love",
            options: .init(
                details: true,
                ebooks: true,
                publishedIn: "1500-1600",
                limit: 10,
                offset: 20
            )
        )

        #expect(subject.key == "love")
        #expect(subject.works.count == 1)
        #expect(subject.coverImageURL?.absoluteString == "https://covers.openlibrary.org/b/id/1234567-L.jpg")
    }

    @Test func testOpenLibraryAPISubjectEndpointLive() async throws {
        let api = OpenLibraryAPI()
        let subject = try await api.getSubject(
            subjectSlug: "love",
            options: .init(details: true, limit: 2)
        )

        #expect(subject.key == "love")
        #expect(subject.works.count > 0)
        #expect(subject.works.first?.title.count ?? 0 > 0)
    }
}

/// A sendable async transport stub used to verify subject request construction.
private struct SubjectSessionStub: OpenLibraryHTTPSession {
    let handler: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await handler(request)
    }
}
