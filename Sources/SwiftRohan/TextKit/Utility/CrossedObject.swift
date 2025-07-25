import Foundation

/// An object that is crossed over from certain location in certain direction.
enum CrossedObject {
  /// String is expected to have length "1". And the location on the other side.
  case text(String, TextLocation)
  /// Node is expected to be not "TextNode". And the location on the other side.
  case nonTextNode(Node, TextLocation)
  /// Cross a block node boundary.
  case blockBoundary

  var isBlockBoundary: Bool {
    if case .blockBoundary = self { return true }
    return false
  }

  func text() -> (string: String, location: TextLocation)? {
    if case let .text(text, location) = self {
      return (text, location)
    }
    return nil
  }

  func nonTextNode() -> (node: Node, location: TextLocation)? {
    if case let .nonTextNode(node, location) = self {
      return (node, location)
    }
    return nil
  }
}
