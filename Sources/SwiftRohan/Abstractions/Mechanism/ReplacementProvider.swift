// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation

public struct ReplacementProvider {
  private let textEngine: ReplacementEngine
  private let mathEngine: ReplacementEngine

  public init(_ rules: [ReplacementRule]) {
    let (rest, both) = rules.partitioned { $0.command.category == .plaintext }
    let (text, math) = rest.partitioned { $0.command.category == .mathContent }

    let textRules = both + text
    let mathRules = both + math

    self.textEngine = ReplacementEngine(textRules)
    self.mathEngine = ReplacementEngine(mathRules)
  }

  func prefixSize(for character: Character, in mode: LayoutMode) -> Int? {
    switch mode {
    case .textMode:
      textEngine.prefixSize(for: character)

    case .mathMode:
      mathEngine.prefixSize(for: character)
    }
  }

  func replacement(
    for character: Character, prefix: String, in mode: LayoutMode
  ) -> (CommandBody, prefix: Int)? {
    switch mode {
    case .textMode:
      textEngine.replacement(for: character, prefix: prefix)

    case .mathMode:
      mathEngine.replacement(for: character, prefix: prefix)
    }
  }

}
