// Copyright 2024-2025 Lie Yan

import Foundation

extension NodeUtils {

  /// Returns true if the offset is valid for the node.
  static func validateOffset(_ offset: Int, _ node: Node) -> Bool {
    switch node {
    case let textNode as TextNode:
      return (0...textNode.length) ~= offset
    case let elementNode as ElementNode:
      return (0...elementNode.childCount) ~= offset
    case let argumentNode as ArgumentNode:
      return (0...argumentNode.childCount) ~= offset
    default:
      return false
    }
  }
}
