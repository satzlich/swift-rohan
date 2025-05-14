// Copyright 2024-2025 Lie Yan

import Foundation

/// - Note: TeX has commands `\mathbb`, `\mathcal`, `\mathfrak`, etc.
public enum MathVariant: String, Equatable, Hashable, Codable, Sendable, CaseIterable {
  /// Serif (default variant)
  case serif
  /// Sans serif
  case sans
  /// Fraktur
  case frak
  /// Monospace
  case mono
  /// Blackboard
  case bb
  /// Calligraphy
  case cal
}
