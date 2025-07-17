// Copyright 2024-2025 Lie Yan

import Foundation

enum ContentType {
  case inline
  case block
}

extension ContentType {
  @inlinable @inline(__always)
  func isCompatible(with container: ContainerType) -> Bool {
    container.isCompatible(with: self)
  }
}
