import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct ContainerTypeTests {
  @Test
  func coverage() {
    for nodeType in NodeType.allCases {
      _ = nodeType.containerType
    }
  }

  @Test
  func isCompatible() {
    for (content, container) in product(ContentType.allCases, ContainerType.allCases) {
      _ = content.isCompatible(with: container)
    }
  }
}
