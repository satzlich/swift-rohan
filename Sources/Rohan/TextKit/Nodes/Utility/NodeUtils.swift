// Copyright 2024-2025 Lie Yan

import Foundation

enum NodeUtils {
  typealias AnnotatedNode = (node: Node, index: RohanIndex)

  static func traceNodes(_ location: TextLocation, _ subtree: Node) -> [AnnotatedNode]? {
    var result = [AnnotatedNode]()
    result.reserveCapacity(location.path.count + 1)

    var node = subtree
    for index in location.path {
      guard let child = node.getChild(index) else { return nil }
      result.append(AnnotatedNode(node, index))
      node = child
    }
    guard validateOffset(location.offset, node) else { return nil }
    result.append(AnnotatedNode(node, .index(location.offset)))

    return result
  }
}
