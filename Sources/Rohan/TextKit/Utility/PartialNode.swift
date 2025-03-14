// Copyright 2024-2025 Lie Yan

import Foundation

/**
 A `PartialNode` is a node that may not be fully initialized, but can be turned
 into one by calling `deepCopy()`.

 - Note: It is used for enumerating contents in a range.
 */
enum PartialNode {
  case original(Node)
  case partialElement(PartialElement)

  func deepCopy() -> Node {
    switch self {
    case let .original(node):
      return node.deepCopy()
    case let .partialElement(partialElement):
      return partialElement.deepCopy()
    }
  }
}
