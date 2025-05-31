// Copyright 2024-2025 Lie Yan

public enum DeparsePreference: String {
  /// Deparse without any modification. May change the semantics of the output.
  case unmodified
  /// Deparse with barely enough grouping so that the construct can be used as
  /// argument and the semantic is preserved.
  case properGroup
  /// Add grouping to a single non-symbol that are not already grouped.
  case wrapNonSymbol
}
