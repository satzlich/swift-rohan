import Foundation
import LatexParser
import _RopeModule

/// A `PartialNode` is a shallow copy of `Node` that is used for representing
/// a part of a `Node` that is sliced. It is not a canonical `Node`, but can be
/// turned into one by calling `deepCopy()`.
///
/// - Note: It is used for enumerating contents in a range.
enum PartialNode: Encodable {
  case original(Node)
  case slicedText(TextNode)
  case slicedElement(SlicedElement)

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

  // MARK: - Clone

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

  // MARK: - Encodable

  func encode(to encoder: any Encoder) throws {
    switch self {
    case let .original(node):
      try node.encode(to: encoder)
    case let .slicedText(slicedText):
      try slicedText.encode(to: encoder)
    case let .slicedElement(slicedElement):
      try slicedElement.encode(to: encoder)
    }
  }
}
