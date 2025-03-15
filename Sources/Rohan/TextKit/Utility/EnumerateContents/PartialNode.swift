// Copyright 2024-2025 Lie Yan

import Foundation

/**
 A `PartialNode` is a node that may not be fully initialized, but can be turned
 into one by calling `deepCopy()`.

 - Note: It is used for enumerating contents in a range.
 */
enum PartialNode {
  case original(Node)
  case slicedText(TextNode)
  case slicedElement(SlicedElement)

  func deepCopy() -> Node {
    switch self {
    case let .original(node):
      return node.deepCopy()
    case let .slicedText(slicedText):
      return slicedText.deepCopy()
    case let .slicedElement(slicedElement):
      return slicedElement.deepCopy()
    }
  }

  func slicedElement() -> SlicedElement? {
    switch self {
    case let .slicedElement(slicedElement):
      return slicedElement
    default:
      return nil
    }
  }

  var isOriginal: Bool {
    switch self {
    case .original: return true
    default: return false
    }
  }
}
