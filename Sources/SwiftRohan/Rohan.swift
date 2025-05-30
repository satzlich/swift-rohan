// Copyright 2024-2025 Lie Yan

import OSLog
import _RopeModule

internal enum Rohan {
  static let domain = "net.satzlich.rohan"
  static let logger = Logger(subsystem: domain, category: "Rohan")

  /// tolerance for layout calculations
  static let tolerance: CGFloat = 1e-6

  /// True if text in math mode should be auto-italicized.
  static let autoItalic: Bool = true
}

typealias RhString = BigString
typealias RhSubstring = BigSubstring

/// Returns the duplicates in the given sequence of strings.
internal func findDuplicates<T: Hashable & Equatable, S: Sequence<T>>(
  in sequences: S
) -> Array<T> {
  var seen = Set<T>()
  var duplicates = Set<T>()

  for element in sequences {
    if seen.contains(element) {
      duplicates.insert(element)
    }
    else {
      seen.insert(element)
    }
  }

  return Array(duplicates)
}
