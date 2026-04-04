//
//  CommandParser.swift
//
//  Created by Codex on 2026-04-04.
//

import Foundation

/// A parsed CLI command.
///
/// The CLI keeps its argument model intentionally small so it remains easy to
/// reason about without pulling in an argument parsing dependency.
enum CLICommand: Equatable {
    case help
    case search(query: String, language: String?, limit: Int)
    case editions(workKey: String, limit: Int)
}

/// Errors that can be emitted by the CLI parser.
///
/// These are user-facing parsing errors, not transport errors. They are mapped
/// to exit codes by the main entry point.
enum CLIError: Error, CustomStringConvertible, Equatable {
    case unknownCommand(String)
    case missingValue(String)
    case invalidLimit(String)
    case missingSearchQuery
    case missingWorkKey

    var description: String {
        switch self {
        case .unknownCommand(let command):
            "Unknown command: \(command)"
        case .missingValue(let option):
            "Missing value for \(option)"
        case .invalidLimit(let value):
            "Invalid limit value: \(value)"
        case .missingSearchQuery:
            "Search requires a query string."
        case .missingWorkKey:
            "Editions requires a work key."
        }
    }

    var exitCode: Int32 {
        64
    }
}

/// Parses command-line arguments into a CLI command.
///
/// The parser is intentionally simple: command names come first, followed by
/// free-form positional tokens and a small set of `--flag value` options.
struct CLIParser {
    /// Parses the argument vector excluding the executable name.
    func parse(_ arguments: [String]) throws -> CLICommand {
        guard let command = arguments.first else {
            return .help
        }

        switch command {
        case "-h", "--help", "help":
            return .help
        case "search":
            return try parseSearch(Array(arguments.dropFirst()))
        case "editions":
            return try parseEditions(Array(arguments.dropFirst()))
        default:
            throw CLIError.unknownCommand(command)
        }
    }

    private func parseSearch(_ arguments: [String]) throws -> CLICommand {
        var queryParts: [String] = []
        var language: String?
        var limit = 5

        var iterator = arguments.makeIterator()
        while let token = iterator.next() {
            switch token {
            case "--language", "-l":
                guard let value = iterator.next() else {
                    throw CLIError.missingValue(token)
                }
                language = value
            case "--limit":
                guard let value = iterator.next() else {
                    throw CLIError.missingValue(token)
                }
                guard let parsedLimit = Int(value), parsedLimit > 0 else {
                    throw CLIError.invalidLimit(value)
                }
                limit = parsedLimit
            case "-h", "--help":
                return .help
            default:
                queryParts.append(token)
            }
        }

        let query = queryParts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            throw CLIError.missingSearchQuery
        }

        return .search(query: query, language: language, limit: limit)
    }

    private func parseEditions(_ arguments: [String]) throws -> CLICommand {
        var positional: [String] = []
        var limit = 5

        var iterator = arguments.makeIterator()
        while let token = iterator.next() {
            switch token {
            case "--limit":
                guard let value = iterator.next() else {
                    throw CLIError.missingValue(token)
                }
                guard let parsedLimit = Int(value), parsedLimit > 0 else {
                    throw CLIError.invalidLimit(value)
                }
                limit = parsedLimit
            case "-h", "--help":
                return .help
            default:
                positional.append(token)
            }
        }

        guard let workKey = positional.first, !workKey.isEmpty else {
            throw CLIError.missingWorkKey
        }

        return .editions(workKey: workKey, limit: limit)
    }
}

/// Human-readable help text for the CLI example.
enum CLIHelp {
    static let usage = """
    Open Library CLI

    Usage:
      openlibrary search <query> [--language <iso639-2>] [--limit <n>]
      openlibrary editions <work-key> [--limit <n>]

    Examples:
      openlibrary search "Pattern Recognition"
      openlibrary search "Foundation" --language eng --limit 3
      openlibrary editions OL45883W --limit 5
    """
}
