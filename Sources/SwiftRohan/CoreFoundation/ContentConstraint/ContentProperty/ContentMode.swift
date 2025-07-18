// Copyright 2024-2025 Lie Yan

import Foundation

enum ContentMode: String, Comparable, Codable, CaseIterable {
  case text
  case math
  /// can be either text or math
  case universal

  /// The order is arbitrary, but it is used for sorting.
  static func < (lhs: ContentMode, rhs: ContentMode) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

extension ContentMode {
  @inlinable @inline(__always)
  func isCompatible(with container: ContainerMode) -> Bool {
    container.isCompatible(with: self)
  }
}

