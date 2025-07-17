// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct ContainerModeTests {
  @Test
  func coverage() {
    for nodeType in NodeType.allCases {
      _ = nodeType.containerMode
    }
  }

  @Test
  func isCompatible() {
    for (content, container) in product(ContentMode.allCases, ContainerMode.allCases) {
      _ = content.isCompatible(with: container)
    }
  }
}
