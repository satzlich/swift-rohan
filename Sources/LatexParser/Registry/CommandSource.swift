public enum CommandSource: String, Codable, Sendable {
  /// Pre-built in LaTeX core, AMS package, unicode-math, etc.
  case preBuilt
  case customExtension
}
