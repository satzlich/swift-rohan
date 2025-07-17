// Copyright 2024-2025 Lie Yan

import Foundation

struct ContainerProperty {
  let containerMode: ContainerMode
  let containerType: ContainerType
}

extension ContainerProperty {
  @inlinable @inline(__always)
  func isCompatible(with content: ContentProperty) -> Bool {
    containerMode.isCompatible(with: content.contentMode)
      && containerType.isCompatible(with: content.contentType)
  }
}
