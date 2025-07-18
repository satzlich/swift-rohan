// Copyright 2024-2025 Lie Yan

import Foundation

enum ContainerMode: CaseIterable {
  case text
  case math
}

extension ContainerMode {
  @inlinable @inline(__always)
  func isCompatible(with content: ContentMode) -> Bool {
    switch (self, content) {
    case (.text, .text): true
    case (.math, .math): true
    case (_, .universal): true
    case _: false
    }
  }
}
