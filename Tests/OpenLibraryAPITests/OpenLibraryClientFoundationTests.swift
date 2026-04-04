import Foundation
import Testing
@testable import OpenLibrary

@Suite("OpenLibrary client foundation")
struct OpenLibraryClientFoundationTests {
    @Test func searchUsesURLComponentsAndIdentificationHeaders() async throws {
        let session = SessionStub { request in
            let url = try #require(request.url)
            let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))

            #expect(components.scheme == "https")
            #expect(components.host == "example.com")
            #expect(components.path == "/search.json")
            #expect(
                components.queryItems?.first(where: { $0.name == "q" })?.value
                    == "Moby-Dick & Co language:eng"
            )
            #expect(
                components.queryItems?.first(where: { $0.name == "fields" })?.value
                    == "*,editions"
            )
            #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
            #expect(request.value(forHTTPHeaderField: "User-Agent") == "OpenLibraryTests/1.0")
            #expect(request.value(forHTTPHeaderField: "From") == "openlibrary-tests@example.com")

            return (
                OpenLibraryAPIMocks.search.data(using: .utf8)!,
                HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            )
        }

        let api = OpenLibraryAPI(
            configuration: .init(
                baseURL: URL(string: "https://example.com")!,
                session: session,
                userAgent: "OpenLibraryTests/1.0",
                contactEmail: "openlibrary-tests@example.com"
            )
        )

        let results = try await api.search(query: "Moby-Dick & Co", language: "eng")
        #expect(results.docs.count == 1)
        #expect(results.numFound == 1)
    }

    @Test func workUsesSharedRequestPathAndBaseURL() async throws {
        let workJSON = """
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

        let session = SessionStub { request in
            let url = try #require(request.url)
            #expect(url.absoluteString == "https://example.com/works/OL45804W.json")

            return (
                Data(workJSON.utf8),
                HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            )
        }

        let api = OpenLibraryAPI(
            configuration: .init(
                baseURL: URL(string: "https://example.com")!,
                session: session
            )
        )

        let work = try await api.getWork(workKey: "OL45804W")
        #expect(work.key == "OL45804W")
        #expect(work.authorKeys == ["OL34184A"])
        #expect(work.description == "A clever fox outwits three farmers.")
    }

    @Test func editionsUseSharedRequestPathAndBaseURL() async throws {
        let session = SessionStub { request in
            let url = try #require(request.url)
            #expect(url.absoluteString == "https://example.com/works/OL45883W/editions.json")

            return (
                OpenLibraryAPIMocks.twitterAndTearGasEditions.data(using: .utf8)!,
                HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            )
        }

        let api = OpenLibraryAPI(
            configuration: .init(
                baseURL: URL(string: "https://example.com")!,
                session: session
            )
        )

        let editions = try await api.getWorkEditions(workKey: "OL45883W")
        #expect(editions.count == 4)
    }

    @Test func unexpectedStatusCodesThrowTypedErrors() async throws {
        let session = SessionStub { request in
            let url = try #require(request.url)
            return (
                Data("slow down".utf8),
                HTTPURLResponse(url: url, statusCode: 429, httpVersion: nil, headerFields: nil)!
            )
        }

        let api = OpenLibraryAPI(
            configuration: .init(
                baseURL: URL(string: "https://example.com")!,
                session: session
            )
        )

        do {
            _ = try await api.search(query: "Dune", language: "eng")
            Issue.record("Expected search to throw for a non-2xx response")
        } catch let error as OpenLibraryAPI.APIError {
            switch error {
            case .unexpectedStatusCode(let code, let body):
                #expect(code == 429)
                #expect(body == "slow down")
            default:
                Issue.record("Expected an unexpectedStatusCode error, received \(error)")
            }
        }
    }
}

/// A sendable async transport stub used to verify request construction.
///
/// This mirrors the production concurrency model: the client awaits a sendable
/// dependency that performs a request and returns immutable `(Data, URLResponse)`
/// values. No global mutable state or unsafe concurrency escapes are required.
private struct SessionStub: OpenLibraryHTTPSession {
    let handler: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await handler(request)
    }
}
