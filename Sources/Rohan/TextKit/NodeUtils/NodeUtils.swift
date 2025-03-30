// Copyright 2024-2025 Lie Yan

import Foundation

enum NodeUtils {

  /// Obtain node at the given location specified by path from subtree.
  /// - Note: This method is used for supporting template.
  static func getNode(at path: [RohanIndex], _ subtree: ElementNode) -> Node? {
    if path.isEmpty { return subtree }

    var node: Node = subtree
    for index in path.dropLast() {
      guard let child = node.getChild(index) else { return nil }
      node = child
    }
    return node.getChild(path.last!)
  }

  /// Compute the layout offset of the given path within subtree.
  /// - Returns: The layout offset of the path within subtree. Or nil if the path
  ///     is invalid.
  /// - Warning: It is required that every node obtained along path be in
  ///     __the same layout context__ as subtree and further more be __non-pivotal__.
  ///     Otherwise, the result is undefined.
  static func computeLayoutOffset(
    for path: ArraySlice<RohanIndex>, _ subtree: Node
  ) -> Int? {
    precondition(!path.isEmpty)
    var s = 0
    var node: Node = subtree
    for index in path.dropLast() {
      guard let n = node.getLayoutOffset(index),
        let child = node.getChild(index),
        // ensure non-piovtal node
        !child.isPivotal
      else { return nil }
      s += n
      node = child
    }
    guard let n = node.getLayoutOffset(path.last!) else { return nil }
    s += n
    return s
  }

  /// Compute the visual delimiter range for a location in the tree.
  static func visualDelimiterRange(
    for location: TextLocation, _ tree: RootNode
  ) -> RhTextRange? {
    guard let trace = Trace.from(location, tree) else { return nil }

    // find the last non-transparent node
    let i = trace.lastIndex(where: { $0.node.isTransparent == false })
    guard let i else { return nil }

    // check if the node needs visual delimiter
    let node = trace[i].node
    guard NodePolicy.needsVisualDelimiter(node.type) else { return nil }

    // take prefix
    let prefix = trace[0..<i].map(\.index)

    switch node {
    case let element as ElementNode:
      let end = element.childCount
      guard end > 0 else { return nil }
      return RhTextRange(TextLocation(prefix, 0), TextLocation(prefix, end))
    case let argument as ArgumentNode:
      let end = argument.childCount
      guard end > 0 else { return nil }
      return RhTextRange(TextLocation(prefix, 0), TextLocation(prefix, end))
    default:
      return nil
    }
  }

  /// Move caret to the next/previous location.
  /// - Returns: The new location of the caret. Nil if the given location is invalid.
  static func destinationLocation(
    for location: TextLocation, _ direction: TextSelectionNavigation.Direction,
    _ rootNode: RootNode
  ) -> TextLocation? {
    precondition([.forward, .backward].contains(direction))

    guard var trace = Trace.from(location, rootNode) else { return nil }

    switch direction {
    case .forward:
      trace.moveForward()
      return trace.toTextLocation()

    case .backward:
      trace.moveBackward()
      return trace.toTextLocation()

    default:
      assertionFailure("Unexpected direction")
      return nil
    }
  }
}
