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
  ///      (a) if a location points to a transparent element, it is relocated to
  ///          the beginning of its children;
  ///      (b) if a location points to a text node, it is relocated to the
  ///          beginning of the text node.
  ///      (c) if a location points to a node neighbouring a text node to its
  ///          left, it is relocated to the end of the text node.
  func toTextLocation() -> TextLocation? {
    guard let last,
      var lastIndex = last.index.index()
    else { return nil }

    var lastNode: Node = last.node
    var indices = _elements.dropLast().map(\.index)

    // Invariant: (indices, lastIndex) forms a location in the tree.
    //            (lastNode, lastIndex) are paired.
    while true {
      switch lastNode {
      case let container as ElementNode where container.isParagraphContainer:
        if lastIndex < container.childCount,
          let child = container.getChild(lastIndex) as? ElementNode,
          child.isTransparent
        {
          // make progress
          indices.append(.index(lastIndex))
          lastNode = child
          lastIndex = 0
          continue
        }
        else {
          return TextLocation(indices, lastIndex)
        }

      case let node as ElementNode:
        if lastIndex < node.childCount,
          isTextNode(node.getChild(lastIndex))
        {
          indices.append(.index(lastIndex))
          return TextLocation(indices, 0)
        }
        else if lastIndex > 0,
          let textNode = node.getChild(lastIndex - 1) as? TextNode
        {
          indices.append(.index(lastIndex - 1))
          return TextLocation(indices, textNode.length)
        }
        else {
          return TextLocation(indices, lastIndex)
        }

      // VERBATIM from "case let node as ElementNode:"
      case let node as ArgumentNode:
        if lastIndex < node.childCount,
          isTextNode(node.getChild(lastIndex))
        {
          indices.append(.index(lastIndex))
          return TextLocation(indices, 0)
        }
        else if lastIndex > 0,
          let textNode = node.getChild(lastIndex - 1) as? TextNode
        {
          indices.append(.index(lastIndex - 1))
          return TextLocation(indices, textNode.length)
        }
        else {
          return TextLocation(indices, lastIndex)
        }

      default:
        return TextLocation(indices, lastIndex)
      }
    }
  }
}
