// Copyright 2024-2025 Lie Yan

import Foundation

struct MathSymbol {
  /// Command sequence
  let command: String

  /// Equivalent Unicode string
  let string: String

  init(_ command: String, _ string: String) {
    self.command = command
    self.string = string
  }
}
