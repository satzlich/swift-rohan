// Copyright 2024-2025 Lie Yan

public enum CommandSource: String, Codable {
  /// Pre-built in LaTeX core, AMS package, unicode-math, etc.
  case preBuilt
  case customExtension
}
