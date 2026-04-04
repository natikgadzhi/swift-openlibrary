import Testing
@testable import OpenLibraryCLI

@Suite("OpenLibrary CLI parser")
struct OpenLibraryCLIParserTests {
    @Test func parsesSearchCommand() throws {
        let command = try CLIParser().parse(["search", "Pattern", "Recognition", "--language", "eng", "--limit", "3"])

        #expect(command == .search(query: "Pattern Recognition", language: "eng", limit: 3))
    }

    @Test func parsesEditionsCommand() throws {
        let command = try CLIParser().parse(["editions", "OL45883W", "--limit", "2"])

        #expect(command == .editions(workKey: "OL45883W", limit: 2))
    }

    @Test func rejectsMissingSearchQuery() throws {
        #expect(throws: CLIError.self) {
            try CLIParser().parse(["search", "--limit", "2"])
        }
    }

    @Test func helpCommandIsRecognized() throws {
        let command = try CLIParser().parse(["--help"])
        #expect(command == .help)
    }
}
