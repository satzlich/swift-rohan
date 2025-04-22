// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms

public struct ReplacementRule {
  let prefix: String
  let character: Character
  let command: CommandBody

  init(_ prefix: String, _ character: Character, _ command: CommandBody) {
    self.prefix = prefix
    self.character = character
    self.command = command
  }
}
