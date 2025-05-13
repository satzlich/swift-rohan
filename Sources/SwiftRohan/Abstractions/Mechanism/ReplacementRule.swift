// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms

public struct ReplacementRule {
  /// prefix to match
  let prefix: String

  /// current character
  let character: Character

  /// command to execute
  let command: CommandBody

  init(_ prefix: String, _ character: Character, _ command: CommandBody) {
    self.prefix = prefix
    self.character = character
    self.command = command
  }

  init(_ sequence: String, _ command: CommandBody) {
    precondition(!sequence.isEmpty)
    self.prefix = String(sequence.dropLast())
    self.character = sequence.last!
    self.command = command
  }
}
