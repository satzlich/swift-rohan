// Copyright 2024-2025 Lie Yan

import OSLog
import _RopeModule

internal enum Rohan {
  static let domain = "net.satzlich.rohan"
  static let logger = Logger(subsystem: domain, category: "Rohan")

  /// tolerance for layout calculations
  static let tolerance: CGFloat = 1e-6
  static let autoItalic: Bool = true
}

typealias RhString = BigString
typealias RhSubstring = BigSubstring

internal func findDuplicates<S: Sequence<String>>(in strings: S) -> [String] {
  var seen = Set<String>()
  var duplicates = Set<String>()

  for string in strings {
    if seen.contains(string) {
      duplicates.insert(string)
    }
    else {
      seen.insert(string)
    }
  }

  return Array(duplicates)
}
