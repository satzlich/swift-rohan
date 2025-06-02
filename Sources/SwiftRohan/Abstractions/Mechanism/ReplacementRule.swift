// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms

public struct ReplacementRule {
  enum Prefix {
    case string(String)
    case extendedString(ExtendedString)

    var count: Int {
      switch self {
      case .string(let s): return s.count
      case .extendedString(let s): return s.count
      }
    }

    var isEmpty: Bool {
      switch self {
      case .string(let s): return s.isEmpty
      case .extendedString(let s): return s.isEmpty
      }
    }

    func toExtendedString() -> ExtendedString {
      switch self {
      case .string(let s): return ExtendedString(s)
      case .extendedString(let s): return s
      }
    }
  }

  /// prefix to match
  let prefix: Prefix

  /// current character
  let character: Character

  /// command to execute
  let command: CommandBody

  init(_ prefix: String, _ character: Character, _ command: CommandBody) {
    self.prefix = .string(prefix)
    self.character = character
    self.command = command
  }

  init(_ sequence: String, _ command: CommandBody) {
    precondition(!sequence.isEmpty)
    self.prefix = .string(String(sequence.dropLast()))
    self.character = sequence.last!
    self.command = command
  }
}
