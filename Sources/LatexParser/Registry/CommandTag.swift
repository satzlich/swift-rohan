// Copyright 2024-2025 Lie Yan

public struct CommandTag: OptionSet, Codable {
  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public static let mathOperator = CommandTag(rawValue: 1 << 0)

  /// Named symbol (math or universal) can be used as superscript or subscript
  /// directly without braces.
  public static let namedSymbol = CommandTag(rawValue: 1 << 1)

  public static let other: CommandTag = []
}
