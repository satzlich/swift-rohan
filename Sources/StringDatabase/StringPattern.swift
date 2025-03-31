// Copyright 2024-2025 Lie Yan

import Foundation

/// Patterns for string matching.
public enum StringPattern {
  /// find a string that equals the pattern
  case exact(String)
  /// find strings that start with the pattern
  case prefix(String)
  /// find strings that contain the pattern as a substring
  case substring(String)
  /// find strings that contain the pattern as a subsequence
  case subsequence(String)
  /// find strings that match the pattern as a regex
  case regex(String)
  /// find strings intelligently with fuzzy matching
  case fuzzy(String)
}
