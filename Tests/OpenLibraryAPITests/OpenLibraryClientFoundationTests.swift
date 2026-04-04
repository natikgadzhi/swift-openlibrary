import Foundation
import Testing
import OpenLibrary

@Suite("OpenLibrary client foundation", .serialized)
struct OpenLibraryClientFoundationTests {
    @Test func searchUsesURLComponentsAndIdentificationHeaders() async throws {
        let session = makeStubbedSession()

        URLProtocolStub.requestHandler = { request in
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
                HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                OpenLibraryAPIMocks.search.data(using: .utf8)!
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

        let results = try await api.searchBooks(query: "Moby-Dick & Co", language: "eng")
        #expect(results.count == 1)
    }

    @Test func editionsUseSharedRequestPathAndBaseURL() async throws {
        let session = makeStubbedSession()

        URLProtocolStub.requestHandler = { request in
            let url = try #require(request.url)
            #expect(url.absoluteString == "https://example.com/works/OL45883W/editions.json")

            return (
                HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                OpenLibraryAPIMocks.twitterAndTearGasEditions.data(using: .utf8)!
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
        let session = makeStubbedSession()

        URLProtocolStub.requestHandler = { request in
            let url = try #require(request.url)
            return (
                HTTPURLResponse(url: url, statusCode: 429, httpVersion: nil, headerFields: nil)!,
                Data("slow down".utf8)
            )
        }

        let api = OpenLibraryAPI(
            configuration: .init(
                baseURL: URL(string: "https://example.com")!,
                session: session
            )
        )

        do {
            _ = try await api.searchBooks(query: "Dune", language: "eng")
            Issue.record("Expected searchBooks to throw for a non-2xx response")
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

    private func makeStubbedSession() -> URLSession {
        URLProtocolStub.reset()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }
}

private final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler:
        (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    static func reset() {
        requestHandler = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
