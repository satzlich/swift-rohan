// Copyright 2024-2025 Lie Yan

import Foundation

/// Options for string matching.
public struct MatchOptions: OptionSet {
  public var rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public static let caseInsensitive = MatchOptions(rawValue: 1 << 0)
}
