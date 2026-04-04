//
//  OpenLibraryCLI.swift
//
//  Created by Codex on 2026-04-04.
//

import Foundation
import OpenLibrary

@main
struct OpenLibraryCLI {
    static func main() async {
        do {
            let parser = CLIParser()
            let command = try parser.parse(Array(CommandLine.arguments.dropFirst()))
            try await run(command)
        } catch let error as CLIError {
            Self.writeError("\(error.description)\n")
            Self.writeError("\n\(CLIHelp.usage)\n")
            exit(error.exitCode)
        } catch {
            Self.writeError("Unexpected error: \(error)\n")
            exit(1)
        }
    }

    private static func run(_ command: CLICommand) async throws {
        let client = OpenLibraryAPI()

        switch command {
        case .help:
            print(CLIHelp.usage)
        case .search(let query, let language, let limit):
            let books = try await client.searchBooks(query: query, language: language)
            printSearchResults(books, query: query, limit: limit)
        case .editions(let workKey, let limit):
            let editions = try await client.getWorkEditions(workKey: workKey)
            printEditions(editions, workKey: workKey, limit: limit)
        }
    }

    private static func printSearchResults(
        _ books: [OpenLibrarySearchResult],
        query: String,
        limit: Int
    ) {
        let visibleBooks = Array(books.prefix(limit))
        print("Search results for \"\(query)\"")
        print("Showing \(visibleBooks.count) of \(books.count) results")

        for (index, book) in visibleBooks.enumerated() {
            print("\n\(index + 1). \(book.title)")
            if let author = book.author {
                print("   Author: \(author)")
            }
            print("   Work key: \(book.key)")
            if let editionCount = book.editionKeys?.count {
                print("   Edition count: \(editionCount)")
            }
            if let coverImageURL = book.coverImageURL {
                print("   Cover: \(coverImageURL.absoluteString)")
            }
        }
    }

    private static func printEditions(
        _ editions: [OpenLibraryEdition],
        workKey: String,
        limit: Int
    ) {
        let visibleEditions = Array(editions.prefix(limit))
        print("Editions for work \(workKey)")
        print("Showing \(visibleEditions.count) of \(editions.count) results")

        for (index, edition) in visibleEditions.enumerated() {
            print("\n\(index + 1). \(edition.title)")
            if let subtitle = edition.subtitle {
                print("   Subtitle: \(subtitle)")
            }
            print("   Edition key: \(edition.key)")
            if let publishDate = edition.publishDate {
                print("   Publish date: \(publishDate)")
            }
            if let format = edition.format?.rawValue {
                print("   Format: \(format)")
            }
            if let coverImageURL = edition.coverImageURL {
                print("   Cover: \(coverImageURL.absoluteString)")
            }
        }
    }

    private static func writeError(_ message: String) {
        if let data = message.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }
}
