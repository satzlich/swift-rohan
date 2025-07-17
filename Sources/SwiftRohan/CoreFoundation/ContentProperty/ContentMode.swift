// Copyright 2024-2025 Lie Yan

import Foundation

enum ContentMode {
  case text
  case math
  /// can be either text or math
  case universal
}

extension ContentMode {
  @inlinable @inline(__always)
  func isCompatible(with container: ContainerMode) -> Bool {
    container.isCompatible(with: self)
  }
}
