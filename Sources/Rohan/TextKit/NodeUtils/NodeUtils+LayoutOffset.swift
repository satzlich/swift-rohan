// Copyright 2024-2025 Lie Yan

import Foundation

extension NodeUtils {
  /**
   Compute the layout offset of the given path within `node`.
   - Returns: The layout offset of the path within `node`. Or `nil` if the path
      is invalid.
   - Warning: It is required that every node along `path` be in the same layout
      context as `node`. Otherwise, the result is __undefined__.
   */
  static func computeLayoutOffset(_ path: ArraySlice<RohanIndex>, _ subtree: Node) -> Int?
  {
    precondition(!path.isEmpty)
    var s = 0
    var node: Node = subtree
    for index in path.dropLast() {
      guard let n = node.getLayoutOffset(index),
        let child = node.getChild(index)
      else { return nil }
      s += n
      node = child
    }
    guard let n = node.getLayoutOffset(path.last!) else { return nil }
    s += n
    return s
  }
}
