// Copyright 2024-2025 Lie Yan

import Foundation

enum NodeUtils {
  static func traceNodes(_ location: TextLocation, _ tree: RootNode) -> [TraceElement]? {
    var trace = [TraceElement]()
    trace.reserveCapacity(location.indices.count + 1)

    var node: Node = tree
    for index in location.indices {
      guard let child = node.getChild(index) else { return nil }
      trace.append(TraceElement(node, index))
      node = child
    }
    guard validateOffset(location.offset, node) else { return nil }
    trace.append(TraceElement(node, .index(location.offset)))

    return trace
  }

  /**
   Trace nodes along the path given by `indices` from `subtree`,
   return the trace and the node at the end of the path.
   */
  static func traceNodes(_ indices: [RohanIndex], _ subtree: Node) -> ([TraceElement], Node)? {
    var trace = [TraceElement]()
    trace.reserveCapacity(indices.count)

    var node: Node = subtree
    for index in indices {
      guard let child = node.getChild(index) else { return nil }
      trace.append(TraceElement(node, index))
      node = child
    }
    return (trace, node)
  }

  /** Trace nodes that contain `[layoutOffset, _ + 1)` from subtree until meeting
   a character of text node or a __pivotal__ child. */
  static func traceNodes(_ layoutOffset: Int, _ subtree: Node) -> [TraceElement]? {
    guard 0..<subtree.layoutLength ~= layoutOffset else { return nil }

    var result: [TraceElement] = []

    var node = subtree
    var layoutOffset = layoutOffset
    while true {
      guard let (index, consumed) = node.getRohanIndex(layoutOffset) else { break }
      result.append(TraceElement(node, index))
      // NOTE: for text node, ``getChild(_:)`` always returns nil
      guard let child = node.getChild(index), !child.isPivotal else { break }
      // make progress
      node = child
      layoutOffset -= consumed
    }
    return result
  }
}
