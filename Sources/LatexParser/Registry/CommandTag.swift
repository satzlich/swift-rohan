// Copyright 2024-2025 Lie Yan

public struct CommandTag: OptionSet, Codable {
  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public static let mathOperator = CommandTag(rawValue: 1 << 0)

  /// Named symbol (math or universal) in LaTeX system that can be used as
  /// superscript or subscript directly without braces.
  /// - Note: `\bot` is a named symbol, but it is implemented a MathExpression
  ///     in the app.
  public static let namedSymbol = CommandTag(rawValue: 1 << 1)

  /// Variable delimiter that can be used in companion with `\left` and `\right`.
  public static let variableDelimiter = CommandTag(rawValue: 1 << 2)

  public static let null: CommandTag = []
}
