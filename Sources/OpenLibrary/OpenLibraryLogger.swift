//
//  Utils.swift
//  OpenLibrary
//
//  Created by Natik Gadzhi on 12/26/24.
//

import Foundation

/// Protocol defining the logging interface for OpenLibrary.
///
/// OpenLibrary doesn't log with `OSLog.Logger` by default to ensure you can use the library on any platform.
/// However, we provide the standard protocol for you to implement. You can pass the logger into ``OpenLibraryAPI`` when making a new client instance.
///
/// If you're building for an Apple platform, `OSLog.Logger` is the easiest option to go with, and it will work out of the box.
///
public protocol OpenLibraryLoggerProtocol: Sendable {
  /// Basic logging functions that implementations must provide
  func debug(_ message: @autoclosure () -> String)
  func info(_ message: @autoclosure () -> String)
  func error(_ message: @autoclosure () -> String)
}

// On Apple platforms, patch extend the default Logger to work with OpenLibrary
//
#if canImport(OSLog)

  import OSLog

  extension Logger: OpenLibraryLoggerProtocol {
    public func debug(_ message: @autoclosure () -> String) {
      let msg = message()
      self.log(level: .debug, "\(msg)")
    }

    public func info(_ message: @autoclosure () -> String) {
      let msg = message()
      self.log(level: .info, "\(msg)")
    }

    public func error(_ message: @autoclosure () -> String) {
      let msg = message()
      self.log(level: .error, "\(msg)")
    }
  }

#endif
