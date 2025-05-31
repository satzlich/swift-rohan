// Copyright 2024-2025 Lie Yan

public enum DeparsePreference: String {
  /// Deparse without any modification. This may change the semantics of the output.
  case unmodified

  /// Deparse with minimal grouping so that the construct can be used as
  /// argument and the semantic is preserved.
  case minGroup

  /// Deparse with minimal grouping while wrap singleton of non-symbol control word.
  case wrapNonSymbol
}
