// Copyright 2024-2025 Lie Yan

import Foundation

extension Trace {
  /// Build a trace from a location in a tree.
  /// - Returns: The trace if the location is valid, otherwise nil.
  static func from(_ location: TextLocation, _ tree: RootNode) -> Trace? {
    var trace = Trace()
    trace.reserveCapacity(location.indices.count + 1)

    var node: Node = tree
    for index in location.indices {
      guard let child = node.getChild(index) else { return nil }
      trace.emplaceBack(node, index)
      node = child
    }
    guard NodeUtils.validateOffset(location.offset, node) else { return nil }
    trace.emplaceBack(node, .index(location.offset))
    return trace
  }

  /// Build a __normalized__ text location from a trace.
  /// - Note: By __"normalized"__, we mean:
  ///      (a) if a location points to a transparent node, it is relocated to
  ///          its first child if it has one;
  ///      (b) if a location points to a text node, it is relocated to the
  ///          beginning of the text node.
  ///      (c) if a location points to a node neighbouring a left text node, it
  ///          is relocated to the end of the left text node.
  func toTextLocation() -> TextLocation? {
    guard let last,
      var offset = last.index.index()
    else { return nil }

    var lastNode: Node = last.node
    var indices = _elements.dropLast().map(\.index)

    // Invariant: (indices, offset) forms a location in the tree.
    //            (lastNode, offset) are paired.
    while true {
      switch lastNode {
      case let container as ElementNode where container.isParagraphContainerLike:
        if offset < container.childCount,
          let child = container.getChild(offset) as? ElementNode,
          child.isTransparent
        {
          // make progress
          indices.append(.index(offset))
          lastNode = child
          offset = 0
          continue
        }
        else {
          return TextLocation(indices, offset)
        }

      case let node as ElementNode:
        if offset < node.childCount,
          isTextNode(node.getChild(offset))
        {
          indices.append(.index(offset))
          return TextLocation(indices, 0)
        }
        else if offset > 0,
          let textNode = node.getChild(offset - 1) as? TextNode
        {
          indices.append(.index(offset - 1))
          return TextLocation(indices, textNode.llength)
        }
        else {
          return TextLocation(indices, offset)
        }

      // VERBATIM from "case let node as ElementNode:"
      case let node as ArgumentNode:
        if offset < node.childCount,
          isTextNode(node.getChild(offset))
        {
          indices.append(.index(offset))
          return TextLocation(indices, 0)
        }
        else if offset > 0,
          let textNode = node.getChild(offset - 1) as? TextNode
        {
          indices.append(.index(offset - 1))
          return TextLocation(indices, textNode.llength)
        }
        else {
          return TextLocation(indices, offset)
        }

      default:
        return TextLocation(indices, offset)
      }
    }
  }
}
