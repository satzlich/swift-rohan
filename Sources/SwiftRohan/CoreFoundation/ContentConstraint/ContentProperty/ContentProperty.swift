// Copyright 2024-2025 Lie Yan

import Foundation

struct ContentProperty: Equatable, Hashable {
  let nodeType: NodeType
  let contentMode: ContentMode
  let contentType: ContentType
  let contentTag: ContentTag?
}

extension ContentProperty {
  func isCompatible(with container: ContainerProperty) -> Bool {
    ConstraintEngine.shared.isCompatible(self, container)
  }
}
