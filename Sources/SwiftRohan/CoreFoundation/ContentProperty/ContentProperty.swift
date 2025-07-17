// Copyright 2024-2025 Lie Yan

import Foundation

struct ContentProperty {
  let contentMode: ContentMode
  let contentType: ContentType
}

extension ContentProperty {
  @inlinable @inline(__always)
  func isCompatible(with container: ContainerProperty) -> Bool {
    container.isCompatible(with: self)
  }
}
