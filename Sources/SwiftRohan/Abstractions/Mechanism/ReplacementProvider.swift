import Algorithms
import Foundation

public struct ReplacementProvider {
  private let textEngine: ReplacementEngine
  private let mathEngine: ReplacementEngine

  public init(_ rules: Array<ReplacementRule>) {
    let (rest, both) = rules.partitioned { $0.command.isUniversal }
    let (text, math) = rest.partitioned { $0.command.isMathOnly }

    let textRules = both + text
    let mathRules = both + math

    self.textEngine = ReplacementEngine(textRules)
    self.mathEngine = ReplacementEngine(mathRules)
  }

  /// Returns the maximum prefix size (number of characters) for the given character.
  /// Or nil if the character is not in the replacement rules.
  func prefixSize(for character: Character, in mode: LayoutMode) -> Int? {
    switch mode {
    case .textMode:
      textEngine.prefixSize(for: character)

    case .mathMode:
      mathEngine.prefixSize(for: character)
    }
  }

  /// Returns the replacement command for the given character the matched prefix
  /// in **reverse** order. Or nil if no replacement rule is matched.
  func replacement(
    for character: Character, prefix: ExtendedString, in mode: LayoutMode
  ) -> (CommandBody, prefix: ExtendedSubstring)? {
    switch mode {
    case .textMode:
      return textEngine.replacement(for: character, prefix: prefix)
    case .mathMode:
      return mathEngine.replacement(for: character, prefix: prefix)
    }
  }

  func replacement(
    for character: Character, prefix: String, in mode: LayoutMode
  ) -> (CommandBody, prefix: ExtendedSubstring)? {
    let prefix = ExtendedString(prefix)
    return replacement(for: character, prefix: prefix, in: mode)
  }
}
