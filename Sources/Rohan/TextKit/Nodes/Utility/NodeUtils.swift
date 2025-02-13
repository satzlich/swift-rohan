// Copyright 2024-2025 Lie Yan

import Foundation

enum NodeUtils {
  typealias TraceElement = (node: Node, index: RohanIndex)

  static func traceNodes(_ location: TextLocation, _ tree: RootNode) -> [TraceElement]? {
    var trace = [TraceElement]()
    trace.reserveCapacity(location.path.count + 1)

    var node: Node = tree
    for index in location.path {
      guard let child = node.getChild(index) else { return nil }
      trace.append(TraceElement(node, index))
      node = child
    }
    guard validateOffset(location.offset, node) else { return nil }
    trace.append(TraceElement(node, .index(location.offset)))

    return trace
  }
}
