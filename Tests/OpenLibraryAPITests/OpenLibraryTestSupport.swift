import Foundation
import OpenLibrary

/// A lightweight sendable transport stub for request/response tests.
struct SessionStub: OpenLibraryHTTPSession {
    let handler: @Sendable (URLRequest) throws -> (Data, URLResponse)

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try handler(request)
    }
}
