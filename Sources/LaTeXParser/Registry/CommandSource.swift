// Copyright 2024-2025 Lie Yan

public enum CommandSource: String, Codable {
  /// LaTeX core, AMS package, or unicode-math
  case builtIn
  case userDefined
}
